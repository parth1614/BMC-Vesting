// multivault.sol -- vault for holding different kinds of ERC20 tokens

// Copyright (C) 2017  DappHub, LLC

pragma solidity >=0.4.23;

import "./auth.sol";
import "./token.sol";

contract DSMultiVault is DSAuth {
    function push(ERC20 token, address dst, uint wad) public auth {
        require(token.transfer(dst, wad), "ds-vault-token-transfer-failed");
    }
    function pull(ERC20 token, address src, uint wad) public auth {
        require(token.transferFrom(src, address(this), wad), "ds-vault-token-transfer-failed");
    }

    function push(ERC20 token, address dst) public {
        push(token, dst, token.balanceOf(address(this)));
    }
    function pull(ERC20 token, address src) public {
        pull(token, src, token.balanceOf(src));
    }

    function mint(DSToken token, uint wad) public auth {
        token.mint(wad);
    }
    function burn(DSToken token, uint wad) public auth {
        token.burn(wad);
    }
    function mint(DSToken token, address guy, uint wad) public auth {
        token.mint(guy, wad);
    }
    function burn(DSToken token, address guy, uint wad) public auth {
        token.burn(guy, wad);
    }

    function burn(DSToken token) public auth {
        token.burn(token.balanceOf(address(this)));
    }
}
