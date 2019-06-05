pragma solidity 0.5.8;

/**
 * @dev Optional metadata extension for ERC-721 non-fungible token standard.
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 The MIT License

Copyright (c) 2017-2018 0xcert, d.o.o. https://0xcert.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */
interface ERC721Metadata
{

  /**
   * @dev Returns a descriptive name for a collection of NFTs in this contract.
   * @return Representing name.
   */
  function name()
    external
    view
    returns (string memory _name);

  /**
   * @dev Returns a abbreviated name for a collection of NFTs in this contract.
   * @return Representing symbol.
   */
  function symbol()
    external
    view
    returns (string memory _symbol);

  /**
   * @dev Returns a distinct Uniform Resource Identifier (URI) for a given asset. It Throws if
   * `_tokenId` is not a valid NFT. URIs are defined in RFC3986. The URI may point to a JSON file
   * that conforms to the "ERC-721 Metadata JSON Schema".
   * @return URI of _tokenId.
   */
  function tokenURI(uint256 _tokenId)
    external
    view
    returns (string memory);

}
