// vault.sol -- vault for holding a single kind of ERC20 tokens

// Copyright (C) 2017  DappHub, LLC

pragma solidity >=0.4.23;

import "./multivault.sol";

contract DSVault is DSMultiVault {
    ERC20  public  token;

    function swap(ERC20 token_) public auth {
        token = token_;
    }

    function push(address dst, uint wad) public {
        push(token, dst, wad);
    }
    function pull(address src, uint wad) public {
        pull(token, src, wad);
    }

    function push(address dst) public {
        push(token, dst);
    }
    function pull(address src) public {
        pull(token, src);
    }

    function mint(uint wad) public {
        super.mint(DSToken(address(token)), wad);
    }
    function burn(uint wad) public {
        super.burn(DSToken(address(token)), wad);
    }

    function burn() public {
        burn(DSToken(address(token)));
    }
}
