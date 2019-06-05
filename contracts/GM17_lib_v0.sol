/**
CREDITS:
// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// More information at https://gist.github.com/chriseth/f9be9d9391efc5beb9704255a8e2989d
Points library and this Struct library modularised by Michael Connor, EY, 2019
*/

pragma solidity ^0.5.8;

import "./Points.sol";

/**
 @title GM17_v0
 @dev Version 0 of verifying key struct format - for GM17 proofs.
 @notice Do not use this example in any production code!
 */


library GM17_lib_v0 {
    using Points for *;

    struct Vk_GM17_v0 {
        Points.G2Point H;
        Points.G1Point Galpha;
        Points.G2Point Hbeta;
        Points.G1Point Ggamma;
        Points.G2Point Hgamma;
        Points.G1Point[] query;
    }

    struct Proof_GM17_v0 {
        Points.G1Point A;
        Points.G2Point B;
        Points.G1Point C;
    }
}
