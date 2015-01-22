# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, conduit, conduitExtra, engineIo, httpTypes, text
, unorderedContainers, wai, waiWebsockets, websockets, yesodCore
}:

cabal.mkDerivation (self: {
  pname = "engine-io-yesod";
  version = "1.0.1";
  sha256 = "0pczmiqrg046r367j071h2hr6p2amw93sqy7j1drd2gdiwaxzn02";
  buildDepends = [
    conduit conduitExtra engineIo httpTypes text unorderedContainers
    wai waiWebsockets websockets yesodCore
  ];
  jailbreak = true;
  meta = {
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
