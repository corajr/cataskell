{-# LANGUAGE ScopedTypeVariables #-}

module Cataskell.GameData.PlayerSpec (main, spec) where

import Test.Hspec
import Test.QuickCheck
import Data.Monoid
import Cataskell.GameData.Basics
import Cataskell.GameData.Player
import Cataskell.GameData.Resources
import Control.Arrow ((&&&))
import Data.Maybe (isNothing)
import Data.Map (Map)
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Control.Lens hiding (elements)

import Cataskell.GameData.BasicsSpec() -- get Arbitrary ResourceCount 
import Cataskell.GameData.ResourcesSpec() -- get Arbitrary ResourceCount 

instance Arbitrary Player where
  arbitrary = do
    i <- elements [0..3]
    name <- elements ["1", "2", "3", "4"]
    color' <- elements [Red, Blue, Orange, White]
    let p = mkPlayer (i, color', name)
    r <- arbitrary
    return $ resources .~ r $ p
  shrink p = tail $ Player <$> [_playerName p, ""]
                           <*> [_playerColor p]
                           <*> [_playerIndex p]
                           <*> [_resources p]
                           <*> [filter (isNothing . preview itemType) $ _constructed p]
                           <*> [_newCards p]
                           <*> [_knights p]
                           <*> [_bonuses p]

instance Arbitrary PlayerIndex where
  arbitrary = toPlayerIndex `fmap` elements [0..3]

newtype PlayerMap = PlayerMap (Map PlayerIndex Player)
  deriving (Eq, Show, Ord)

instance Arbitrary PlayerMap where
  arbitrary = do
    (xs :: [Player]) <- arbitrary
    let xs' = map (_playerIndex &&& id) xs
    pure . PlayerMap $ Map.fromList xs'

main :: IO ()
main = hspec spec

spec :: Spec
spec = parallel $ do
  describe "A Player" $ do
    let p = mkPlayer (0, Blue, "Nobody")
    it "has a name" $ do
      view playerName p `shouldBe` "Nobody"
    it "has a player index" $ do
      view playerIndex p `shouldBe` toPlayerIndex 0
    it "should begin with 0 resources" $ do
      (totalResources $ view resources p) `shouldBe` 0
    it "can add resources" $ property $
      \p -> let resCountNow = totalResources $ view resources (p :: Player)
                oneOre = mempty { ore = 1 }
                resAfter = (view resources p) <> oneOre
                resCountAfter = totalResources resAfter
            in (resCountNow + 1) == resCountAfter
 
    let c' = [ Card VictoryPoint
             , settlement $ Just (undefined, White)
             , settlement $ Just (undefined, White)]
    let p2 = constructed .~ c' $ (mkPlayer (2, White, "No-One"))
    it "should have a score" $ do
      view score p2 `shouldBe` 3
    it "should have a display score" $ do
      view displayScore p2 `shouldBe` 2
    it "can have development cards" $ do
      view devCards p2 `shouldBe` [VictoryPoint]
    it "must have only non-negative resources" $ property $ do
      \player -> nonNegative $ view resources (player :: Player)
  describe "A Map PlayerIndex Player" $
    it "should have keys matching the PlayerIndex stored in the player object" $ property $
      \(PlayerMap pmap)-> all (\(pI, p) -> pI == (p^.playerIndex)) $ Map.toList pmap
