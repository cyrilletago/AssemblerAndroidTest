// //////////////////////////////////////////////////////////////////////////////;
// // gfpmul.S: Multiplication in pseudo-Mersenne prime fields (for Keil MDK).  //
// // This file is part of PedComArm, an ARM library for Pedersen commitments.  //
// // Project repository: <http://bitbucket.org/christian_franck/pedcomlib/>.   //
// // Version 1.0.0 (2017-06-20), see project repository for latest version.    //
// // Authors: C. Franck and J. Groszschaedl (SnT, University of Luxembourg).   //
// // License: GPLv3 (see LICENSE file), other licenses available on request.   //
// // Copyright (C) 2016-2017 University of Luxembourg <http://www.uni.lu/>.    //
// // ------------------------------------------------------------------------- //
// // This program is free software: you can redistribute it and/or modify it   //
// // under the terms of the GNU General Public License as published by the     //
// // Free Software Foundation, either version 3 of the License, or (at your    //
// // option) any later version. This program is distributed in the hope that   //
// // it will be useful, but WITHOUT ANY WARRANTY; without even the implied     //
// // warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the  //
// // GNU General Public License for more details. You should have received a   //
// // copy of the GNU General Public License along with this program. If not,   //
// // see <http://www.gnu.org/licenses/>.                                       //
// //////////////////////////////////////////////////////////////////////////////;

.text
    // AREA gfp_mul, CODE, READONLY
    
    // EXPORT gfp_mul_128
    // EXPORT gfp_mul_160
    // EXPORT gfp_mul_192
    // EXPORT gfp_mul_224
    // EXPORT gfp_mul_256
    // ALIGN 2
    
    
// ////////////////////
// // Register Names //
// ////////////////////
    
// // register rStart holds the start address of array <r>
#define rStart r0 // rStart RN r0

// // register aStart holds the start address of array <a>
#define aStart r1 // aStart RN r1

// // register bStart holds the start address of array <b>
#define bStart r2 // bStart RN r2

// // register tStart holds the start address of a temporary array for the product
#define tStart sp // tStart RN sp

// // register cParam holds the parameter <c> that defines the prime
#define cParam r3 // cParam RN r3

// // register mulOp1 holds the first operand of a multiplication
#define mulOp1 r4 // mulOp1 RN r4

// // register mulOp2 holds the second operand of a multiplication
#define mulOp2 r5 // mulOp2 RN r5

// // register prodLo holds the lower part of a 64-bit product
#define prodLo r4 // prodLo RN r4

// // register prodHi holds the higher part of a 64-bit product
#define prodHi r5 // prodHi RN r5

// // register accuLo holds the lower part of a 96-bit accumulator
#define accuLo r6 // accuLo RN r6

// // register accuHi holds the higher part of a 96-bit accumulator
#define accuHi r7 // accuHi RN r7

// // register accuEx holds the extension part of a 96-bit accumulator
#define accuEx r8 // accuEx RN r8

// // register loWord holds the lower part of a 64-bit quantity (used in red.)
#define loWord r6 // loWord RN r6

// // register hiWord holds the higher part of a 64-bit quantity (used in red.)
#define hiWord r7 // hiWord RN r7


// ////////////
// // Macros //
// ////////////
    

    .macro gfpmul_prologue tmpSpace:req
    push  {r4-r8}
    sub   sp, sp, #\tmpSpace
    .endm
    
    .macro gfpmul_epilogue tmpSpace:req
    add   sp, sp, #\tmpSpace
    pop   {r4-r8}
    bx    lr
    .endm
    
    .macro mul_and_acc_1st aOffset:req, bOffset:req
    ldr   mulOp1, [aStart, #\aOffset]
    ldr   mulOp2, [bStart, #\bOffset]
    umull accuLo, accuHi, mulOp1, mulOp2
    mov   accuEx, #0
    .endm
    
    .macro mul_and_acc_mid aOffset:req, bOffset:req
    ldr   mulOp1, [aStart, #\aOffset]
    ldr   mulOp2, [bStart, #\bOffset]
    umull prodLo, prodHi, mulOp1, mulOp2
    adds  accuLo, accuLo, prodLo
    adcs  accuHi, accuHi, prodHi
    adc   accuEx, accuEx, #0
    .endm
    
    .macro store_and_shift tOffset:req
    str   accuLo, [tStart, #\tOffset]
    mov   accuLo, accuHi
    mov   accuHi, accuEx
    mov   accuEx, #0
    .endm
    
    .macro store_last_prod tOffset:req
    str   accuLo, [tStart, #\tOffset]
    str   accuHi, [tStart, #(4+\tOffset)]
    .endm
    
    .macro red_mul_add_1st lOffset:req, hOffset:req
    lsl   cParam, cParam, #1
    ldr   mulOp1, [tStart, #\hOffset]
    umull prodLo, prodHi, mulOp1, cParam
    ldr   loWord, [tStart, #\lOffset]
    adds  prodLo, prodLo, loWord
    adc   prodHi, prodHi, #0
    str   prodLo, [rStart, #\lOffset]
    mov   hiWord, prodHi
    .endm
    
    .macro red_mul_add_mid lOffset:req, hOffset:req
    ldr   mulOp1, [tStart, #\hOffset]
    umull prodLo, prodHi, mulOp1, cParam
    ldr   loWord, [tStart, #\lOffset]
    adds  prodLo, prodLo, loWord
    adc   prodHi, prodHi, #0
    adds  prodLo, prodLo, hiWord
    adc   prodHi, prodHi, #0
    str   prodLo, [rStart, #\lOffset]
    mov   hiWord, prodHi
    .endm
    
    .macro red_mul_add_fin lOffset:req, hOffset:req
    ldr   mulOp1, [tStart, #\hOffset]
    umull prodLo, prodHi, mulOp1, cParam
    ldr   loWord, [tStart, #\lOffset]
    adds  prodLo, prodLo, loWord
    adc   prodHi, prodHi, #0
    adds  prodLo, prodLo, hiWord
    adc   prodHi, prodHi, #0
    lsls  prodLo, prodLo, #1
    adc   prodHi, prodHi, prodHi
    lsr   prodLo, prodLo, #1
    str   prodLo, [rStart, #\lOffset]
    .endm
    
    .macro red_st2_mul_add lOffset:req, hOffset:req
    lsr   cParam, cParam, #1
    umull prodLo, prodHi, prodHi, cParam
    ldr   loWord, [rStart, #\lOffset]
    ldr   hiWord, [rStart, #\hOffset]
    adds  prodLo, prodLo, loWord
    adcs  prodHi, prodHi, hiWord
    str   prodLo, [rStart, #\lOffset]
    str   prodHi, [rStart, #\hOffset]
    .endm
    
    .macro propagate_carry rOffset:req
    ldr   loWord, [rStart, #\rOffset]
    adcs  loWord, loWord, #0
    str   loWord, [rStart, #\rOffset]
    .endm
    
    
////////////////////////////////////
// 128-bit modular multiplication //
////////////////////////////////////

.global gfp_mul_128
gfp_mul_128:
    
    // // push registers
    gfpmul_prologue 32
    
    // // column 0
    mul_and_acc_1st 0, 0
    store_and_shift 0
    
    // // column 1
    mul_and_acc_mid 0, 4
    mul_and_acc_mid 4, 0
    store_and_shift 4
    
    // // column 2
    mul_and_acc_mid 0, 8
    mul_and_acc_mid 4, 4
    mul_and_acc_mid 8, 0
    store_and_shift 8
    
    // // column 3
    mul_and_acc_mid 0, 12
    mul_and_acc_mid 4, 8
    mul_and_acc_mid 8, 4
    mul_and_acc_mid 12, 0
    store_and_shift 12
    
    // // column 4
    mul_and_acc_mid 4, 12
    mul_and_acc_mid 8, 8
    mul_and_acc_mid 12, 4
    store_and_shift 16
    
    // // column 5
    mul_and_acc_mid 8, 12
    mul_and_acc_mid 12, 8
    store_and_shift 20
    
    // // column 6
    mul_and_acc_mid 12, 12
    store_last_prod 24
    
    // // reduction step 1
    red_mul_add_1st 0, 16
    red_mul_add_mid 4, 20
    red_mul_add_mid 8, 24
    red_mul_add_fin 12, 28
    
    // // reduction step 2
    red_st2_mul_add 0, 4
    propagate_carry 8
    propagate_carry 12
    
    // // pop registers
    gfpmul_epilogue 32
    

    
    
// ////////////////////////////////////
// // 160-bit modular multiplication //
// ////////////////////////////////////

.global gfp_mul_160
gfp_mul_160:
    
    // // push registers
    gfpmul_prologue 40
    
    // // column 0
    mul_and_acc_1st 0, 0
    store_and_shift 0
    
    // // column 1
    mul_and_acc_mid 0, 4
    mul_and_acc_mid 4, 0
    store_and_shift 4
    
    // // column 2
    mul_and_acc_mid 0, 8
    mul_and_acc_mid 4, 4
    mul_and_acc_mid 8, 0
    store_and_shift 8
    
    // // column 3
    mul_and_acc_mid 0, 12
    mul_and_acc_mid 4, 8
    mul_and_acc_mid 8, 4
    mul_and_acc_mid 12, 0
    store_and_shift 12
    
    // // column 4
    mul_and_acc_mid 0, 16
    mul_and_acc_mid 4, 12
    mul_and_acc_mid 8, 8
    mul_and_acc_mid 12, 4
    mul_and_acc_mid 16, 0
    store_and_shift 16
    
    // // column 5
    mul_and_acc_mid 4, 16
    mul_and_acc_mid 8, 12
    mul_and_acc_mid 12, 8
    mul_and_acc_mid 16, 4
    store_and_shift 20
    
    // // column 6
    mul_and_acc_mid 8, 16
    mul_and_acc_mid 12, 12
    mul_and_acc_mid 16, 8
    store_and_shift 24
    
    // // column 7
    mul_and_acc_mid 12, 16
    mul_and_acc_mid 16, 12
    store_and_shift 28
    
    // column 8
    mul_and_acc_mid 16, 16
    store_last_prod 32
    
    // // reduction step 1
    red_mul_add_1st 0, 20
    red_mul_add_mid 4, 24
    red_mul_add_mid 8, 28
    red_mul_add_mid 12, 32
    red_mul_add_fin 16, 36
    
    // // reduction step 2
    red_st2_mul_add 0, 4
    propagate_carry 8
    propagate_carry 12
    propagate_carry 16
    
    // // pop registers
    gfpmul_epilogue 40
    

    
    
// ////////////////////////////////////
// // 192-bit modular multiplication //
// ////////////////////////////////////
.global gfp_mul_192
gfp_mul_192:
    
    // // push registers
    gfpmul_prologue 48
    
    // // column 0
    mul_and_acc_1st 0, 0
    store_and_shift 0
    
    // // column 1
    mul_and_acc_mid 0, 4
    mul_and_acc_mid 4, 0
    store_and_shift 4
    
    // // column 2
    mul_and_acc_mid 0, 8
    mul_and_acc_mid 4, 4
    mul_and_acc_mid 8, 0
    store_and_shift 8
    
    // // column 3
    mul_and_acc_mid 0, 12
    mul_and_acc_mid 4, 8
    mul_and_acc_mid 8, 4
    mul_and_acc_mid 12, 0
    store_and_shift 12
    
    // // column 4
    mul_and_acc_mid 0, 16
    mul_and_acc_mid 4, 12
    mul_and_acc_mid 8, 8
    mul_and_acc_mid 12, 4
    mul_and_acc_mid 16, 0
    store_and_shift 16
    
    // // column 5
    mul_and_acc_mid 0, 20
    mul_and_acc_mid 4, 16
    mul_and_acc_mid 8, 12
    mul_and_acc_mid 12, 8
    mul_and_acc_mid 16, 4
    mul_and_acc_mid 20, 0
    store_and_shift 20
    
    // // column 6
    mul_and_acc_mid 4, 20
    mul_and_acc_mid 8, 16
    mul_and_acc_mid 12, 12
    mul_and_acc_mid 16, 8
    mul_and_acc_mid 20, 4
    store_and_shift 24
    
    // // column 7
    mul_and_acc_mid 8, 20
    mul_and_acc_mid 12, 16
    mul_and_acc_mid 16, 12
    mul_and_acc_mid 20, 8
    store_and_shift 28
    
    // // column 8
    mul_and_acc_mid 12, 20
    mul_and_acc_mid 16, 16
    mul_and_acc_mid 20, 12
    store_and_shift 32
    
    // // column 9
    mul_and_acc_mid 16, 20
    mul_and_acc_mid 20, 16
    store_and_shift 36
    
    // // column 10
    mul_and_acc_mid 20, 20
    store_last_prod 40
    
    // // reduction step 1
    red_mul_add_1st 0, 24
    red_mul_add_mid 4, 28
    red_mul_add_mid 8, 32
    red_mul_add_mid 12, 36
    red_mul_add_mid 16, 40
    red_mul_add_fin 20, 44
    
    // // reduction step 2
    red_st2_mul_add 0, 4
    propagate_carry 8
    propagate_carry 12
    propagate_carry 16
    propagate_carry 20
    
    // // pop registers
    gfpmul_epilogue 48

    
    
////////////////////////////////////
// 224-bit modular multiplication //
////////////////////////////////////
.global gfp_mul_224
gfp_mul_224:
    
    // push registers
    gfpmul_prologue 56
    
    // column 0
    mul_and_acc_1st 0, 0
    store_and_shift 0
    
    // column 1
    mul_and_acc_mid 0, 4
    mul_and_acc_mid 4, 0
    store_and_shift 4
    
    // column 2
    mul_and_acc_mid 0, 8
    mul_and_acc_mid 4, 4
    mul_and_acc_mid 8, 0
    store_and_shift 8
    
    // column 3
    mul_and_acc_mid 0, 12
    mul_and_acc_mid 4, 8
    mul_and_acc_mid 8, 4
    mul_and_acc_mid 12, 0
    store_and_shift 12
    
    // column 4
    mul_and_acc_mid 0, 16
    mul_and_acc_mid 4, 12
    mul_and_acc_mid 8, 8
    mul_and_acc_mid 12, 4
    mul_and_acc_mid 16, 0
    store_and_shift 16
    
    // column 5
    mul_and_acc_mid 0, 20
    mul_and_acc_mid 4, 16
    mul_and_acc_mid 8, 12
    mul_and_acc_mid 12, 8
    mul_and_acc_mid 16, 4
    mul_and_acc_mid 20, 0
    store_and_shift 20
    
    // column 6
    mul_and_acc_mid 0, 24
    mul_and_acc_mid 4, 20
    mul_and_acc_mid 8, 16
    mul_and_acc_mid 12, 12
    mul_and_acc_mid 16, 8
    mul_and_acc_mid 20, 4
    mul_and_acc_mid 24, 0
    store_and_shift 24
    
    // column 7
    mul_and_acc_mid 4, 24
    mul_and_acc_mid 8, 20
    mul_and_acc_mid 12, 16
    mul_and_acc_mid 16, 12
    mul_and_acc_mid 20, 8
    mul_and_acc_mid 24, 4
    store_and_shift 28
    
    // column 8
    mul_and_acc_mid 8, 24
    mul_and_acc_mid 12, 20
    mul_and_acc_mid 16, 16
    mul_and_acc_mid 20, 12
    mul_and_acc_mid 24, 8
    store_and_shift 32
    
    // column 9
    mul_and_acc_mid 12, 24
    mul_and_acc_mid 16, 20
    mul_and_acc_mid 20, 16
    mul_and_acc_mid 24, 12
    store_and_shift 36
    
    // column 10
    mul_and_acc_mid 16, 24
    mul_and_acc_mid 20, 20
    mul_and_acc_mid 24, 16
    store_and_shift 40
    
    // column 11
    mul_and_acc_mid 20, 24
    mul_and_acc_mid 24, 20
    store_and_shift 44
    
    // column 12
    mul_and_acc_mid 24, 24
    store_last_prod 48
    
    // reduction step 1
    red_mul_add_1st 0, 28
    red_mul_add_mid 4, 32
    red_mul_add_mid 8, 36
    red_mul_add_mid 12, 40
    red_mul_add_mid 16, 44
    red_mul_add_mid 20, 48
    red_mul_add_fin 24, 52
    
    // reduction step 2
    red_st2_mul_add 0, 4
    propagate_carry 8
    propagate_carry 12
    propagate_carry 16
    propagate_carry 20
    propagate_carry 24
    
    // pop registers
    gfpmul_epilogue 56


    
    
////////////////////////////////////
// 256-bit modular multiplication //
////////////////////////////////////
.global gfp_mul_256
gfp_mul_256:
    
    // push registers
    gfpmul_prologue 64
    
    // column 0
    mul_and_acc_1st 0, 0
    store_and_shift 0
    
    // column 1
    mul_and_acc_mid 0, 4
    mul_and_acc_mid 4, 0
    store_and_shift 4
    
    // column 2
    mul_and_acc_mid 0, 8
    mul_and_acc_mid 4, 4
    mul_and_acc_mid 8, 0
    store_and_shift 8
    
    // column 3
    mul_and_acc_mid 0, 12
    mul_and_acc_mid 4, 8
    mul_and_acc_mid 8, 4
    mul_and_acc_mid 12, 0
    store_and_shift 12
    
    // column 4
    mul_and_acc_mid 0, 16
    mul_and_acc_mid 4, 12
    mul_and_acc_mid 8, 8
    mul_and_acc_mid 12, 4
    mul_and_acc_mid 16, 0
    store_and_shift 16
    
    // column 5
    mul_and_acc_mid 0, 20
    mul_and_acc_mid 4, 16
    mul_and_acc_mid 8, 12
    mul_and_acc_mid 12, 8
    mul_and_acc_mid 16, 4
    mul_and_acc_mid 20, 0
    store_and_shift 20
    
    // column 6
    mul_and_acc_mid 0, 24
    mul_and_acc_mid 4, 20
    mul_and_acc_mid 8, 16
    mul_and_acc_mid 12, 12
    mul_and_acc_mid 16, 8
    mul_and_acc_mid 20, 4
    mul_and_acc_mid 24, 0
    store_and_shift 24
    
    // column 7
    mul_and_acc_mid 0, 28
    mul_and_acc_mid 4, 24
    mul_and_acc_mid 8, 20
    mul_and_acc_mid 12, 16
    mul_and_acc_mid 16, 12
    mul_and_acc_mid 20, 8
    mul_and_acc_mid 24, 4
    mul_and_acc_mid 28, 0
    store_and_shift 28
    
    // column 8
    mul_and_acc_mid 4, 28
    mul_and_acc_mid 8, 24
    mul_and_acc_mid 12, 20
    mul_and_acc_mid 16, 16
    mul_and_acc_mid 20, 12
    mul_and_acc_mid 24, 8
    mul_and_acc_mid 28, 4
    store_and_shift 32
    
    // column 9
    mul_and_acc_mid 8, 28
    mul_and_acc_mid 12, 24
    mul_and_acc_mid 16, 20
    mul_and_acc_mid 20, 16
    mul_and_acc_mid 24, 12
    mul_and_acc_mid 28, 8
    store_and_shift 36
    
    // column 10
    mul_and_acc_mid 12, 28
    mul_and_acc_mid 16, 24
    mul_and_acc_mid 20, 20
    mul_and_acc_mid 24, 16
    mul_and_acc_mid 28, 12
    store_and_shift 40
    
    // column 11
    mul_and_acc_mid 16, 28
    mul_and_acc_mid 20, 24
    mul_and_acc_mid 24, 20
    mul_and_acc_mid 28, 16
    store_and_shift 44
    
    // column 12
    mul_and_acc_mid 20, 28
    mul_and_acc_mid 24, 24
    mul_and_acc_mid 28, 20
    store_and_shift 48
    
    // column 13
    mul_and_acc_mid 24, 28
    mul_and_acc_mid 28, 24
    store_and_shift 52
    
    // column 14
    mul_and_acc_mid 28, 28
    store_last_prod 56
    
    // reduction step 1
    red_mul_add_1st 0, 32
    red_mul_add_mid 4, 36
    red_mul_add_mid 8, 40
    red_mul_add_mid 12, 44
    red_mul_add_mid 16, 48
    red_mul_add_mid 20, 52
    red_mul_add_mid 24, 56
    red_mul_add_fin 28, 60
    
    // reduction step 2
    red_st2_mul_add 0, 4
    propagate_carry 8
    propagate_carry 12
    propagate_carry 16
    propagate_carry 20
    propagate_carry 24
    propagate_carry 28
    
    // pop registers
    gfpmul_epilogue 64
    

