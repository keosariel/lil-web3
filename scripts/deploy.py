from urllib3 import Retry
from brownie import (accounts, config, network, 
                    LilVoting, LilEscrow, LilDivorce,
                    LilMultiSigWallet)
import os

def get_account():
    if (network.show_active() == "develpoment"):
        return accounts[0]
    else:   
        return accounts.add(config["wallets"]["from_key"])


def main():
    account =  get_account()
    lil_voting  = LilVoting.deploy({"from": account})
    lil_escrow  = LilEscrow.deploy({"from": account})
    # lil_divorce = LilDivorce.deploy({"from": account})
    # lil_multisig_wallet = LilMultiSigWallet.deploy({"from": account})
