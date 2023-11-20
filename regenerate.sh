  cd contracts
  forge build
  cd ..
  go run utils/contract-deployment/contractDeploymentTools.go constructKeylessTx contracts/out/f2-1.sol/TeleporterMessenger.json