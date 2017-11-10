/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm

import org.itemis.types.UnsignedByte
import java.util.EnumMap
import org.apache.commons.lang3.tuple.Triple
import org.itemis.types.EVMWord
import java.util.function.Consumer
import org.itemis.evm.op.StopAndArithmeticOperations
import org.itemis.evm.op.ComparisonAndBitwiseLogicOperations
import org.itemis.evm.op.SHA3
import org.itemis.evm.op.EnvironmentalInformation
import org.itemis.evm.op.BlockInformation
import org.itemis.evm.op.StackMemoryStorageAndFlowOperations
import org.itemis.evm.op.PushOperations
import org.itemis.evm.op.DuplicationOperations
import org.itemis.evm.op.ExchangeOperations
import org.itemis.evm.op.LoggingOperations
import org.itemis.evm.op.SystemOperations

abstract class EVMOperation {
  public static enum OpCode {
    STOP,
    ADD,
    MUL,
    SUB,
    DIV,
    SDIV,
    MOD,
    SMOD,
    ADDMOD,
    MULMOD,
    EXP,
    SIGNEXTEND,
    LT,
    GT,
    SLT,
    SGT,
    EQ,
    ISZERO,
    AND,
    OR,
    XOR,
    NOT,
    BYTE,
    SHA3,
    ADDRESS,
    BALANCE,
    ORIGIN,
    CALLER,
    CALLVALUE,
    CALLDATALOAD,
    CALLDATASIZE,
    CALLDATACOPY,
    CODESIZE,
    CODECOPY,
    GASPRICE,
    EXTCODESIZE,
    EXTCODECOPY,
    BLOCKHASH,
    COINBASE,
    TIMESTAMP,
    NUMBER,
    DIFFICULTY,
    GASLIMIT,
    POP,
    MLOAD,
    MSTORE,
    MSTORE8,
    SLOAD,
    SSTORE,
    JUMP,
    JUMPI,
    PC,
    MSIZE,
    GAS,
    JUMPDEST,
    PUSH1,
    PUSH2,
    PUSH3,
    PUSH4,
    PUSH5,
    PUSH6,
    PUSH7,
    PUSH8,
    PUSH9,
    PUSH10,
    PUSH11,
    PUSH12,
    PUSH13,
    PUSH14,
    PUSH15,
    PUSH16,
    PUSH17,
    PUSH18,
    PUSH19,
    PUSH20,
    PUSH21,
    PUSH22,
    PUSH23,
    PUSH24,
    PUSH25,
    PUSH26,
    PUSH27,
    PUSH28,
    PUSH29,
    PUSH30,
    PUSH31,
    PUSH32,
    DUP1,
    DUP2,
    DUP3,
    DUP4,
    DUP5,
    DUP6,
    DUP7,
    DUP8,
    DUP9,
    DUP10,
    DUP11,
    DUP12,
    DUP13,
    DUP14,
    DUP15,
    DUP16,
    SWAP1,
    SWAP2,
    SWAP3,
    SWAP4,
    SWAP5,
    SWAP6,
    SWAP7,
    SWAP8,
    SWAP9,
    SWAP10,
    SWAP11,
    SWAP12,
    SWAP13,
    SWAP14,
    SWAP15,
    SWAP16,
    LOG0,
    LOG1,
    LOG2,
    LOG3,
    LOG4,
    CREATE,
    CALL,
    CALLCODE,
    RETURN,
    DELEGATECALL,
    INVALID,
    SELFDESTRUCT
  }
  
  //<OpValue, words taken from stack, words added to stack> 
  public static final EnumMap<OpCode, Triple<UnsignedByte, Pair<UnsignedByte, UnsignedByte>, Consumer<EVMRuntime>>> OP_INFO = {
    val EnumMap<OpCode, Triple<UnsignedByte, Pair<UnsignedByte, UnsignedByte>, Consumer<EVMRuntime>>> result = new EnumMap(OpCode)
    result.put(OpCode.STOP,          Triple.of(new UnsignedByte(0x00), Pair.of(new UnsignedByte(0),  new UnsignedByte(0)),  [StopAndArithmeticOperations::STOP(it)]))           
    result.put(OpCode.ADD,           Triple.of(new UnsignedByte(0x01), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::ADD(it)]))               
    result.put(OpCode.MUL,           Triple.of(new UnsignedByte(0x02), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::MUL(it)]))               
    result.put(OpCode.SUB,           Triple.of(new UnsignedByte(0x03), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::SUB(it)]))               
    result.put(OpCode.DIV,           Triple.of(new UnsignedByte(0x04), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::DIV(it)]))               
    result.put(OpCode.SDIV,          Triple.of(new UnsignedByte(0x05), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::SDIV(it)]))               
    result.put(OpCode.MOD,           Triple.of(new UnsignedByte(0x06), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::MOD(it)]))               
    result.put(OpCode.SMOD,          Triple.of(new UnsignedByte(0x07), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::SMOD(it)]))               
    result.put(OpCode.ADDMOD,        Triple.of(new UnsignedByte(0x08), Pair.of(new UnsignedByte(3),  new UnsignedByte(1)),  [StopAndArithmeticOperations::ADDMOD(it)]))               
    result.put(OpCode.MULMOD,        Triple.of(new UnsignedByte(0x09), Pair.of(new UnsignedByte(3),  new UnsignedByte(1)),  [StopAndArithmeticOperations::MULMOD(it)]))               
    result.put(OpCode.EXP,           Triple.of(new UnsignedByte(0x0A), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::EXP(it)]))               
    result.put(OpCode.SIGNEXTEND,    Triple.of(new UnsignedByte(0x0B), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [StopAndArithmeticOperations::SIGNEXTEND(it)]))               
    result.put(OpCode.LT,            Triple.of(new UnsignedByte(0x10), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::LT(it)]))               
    result.put(OpCode.GT,            Triple.of(new UnsignedByte(0x11), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::GT(it)]))               
    result.put(OpCode.SLT,           Triple.of(new UnsignedByte(0x12), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::SLT(it)]))               
    result.put(OpCode.SGT,           Triple.of(new UnsignedByte(0x13), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::SGT(it)]))               
    result.put(OpCode.EQ,            Triple.of(new UnsignedByte(0x14), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::EQ(it)]))               
    result.put(OpCode.ISZERO,        Triple.of(new UnsignedByte(0x15), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::ISZERO(it)]))               
    result.put(OpCode.AND,           Triple.of(new UnsignedByte(0x16), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::AND(it)]))               
    result.put(OpCode.OR,            Triple.of(new UnsignedByte(0x17), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::OR(it)]))               
    result.put(OpCode.XOR,           Triple.of(new UnsignedByte(0x18), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::XOR(it)]))               
    result.put(OpCode.NOT,           Triple.of(new UnsignedByte(0x19), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::NOT(it)]))               
    result.put(OpCode.BYTE,          Triple.of(new UnsignedByte(0x1A), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [ComparisonAndBitwiseLogicOperations::BYTE(it)]))               
    result.put(OpCode.SHA3,          Triple.of(new UnsignedByte(0x20), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [SHA3::SHA3(it)]))               
    result.put(OpCode.ADDRESS,       Triple.of(new UnsignedByte(0x30), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [EnvironmentalInformation::ADDRESS(it)]))               
    result.put(OpCode.BALANCE,       Triple.of(new UnsignedByte(0x31), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [EnvironmentalInformation::BALANCE(it)]))               
    result.put(OpCode.ORIGIN,        Triple.of(new UnsignedByte(0x32), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [EnvironmentalInformation::ORIGIN(it)]))               
    result.put(OpCode.CALLER,        Triple.of(new UnsignedByte(0x33), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [EnvironmentalInformation::CALLER(it)]))               
    result.put(OpCode.CALLVALUE,     Triple.of(new UnsignedByte(0x34), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [EnvironmentalInformation::CALLVALUE(it)]))               
    result.put(OpCode.CALLDATALOAD,  Triple.of(new UnsignedByte(0x35), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [EnvironmentalInformation::CALLDATALOAD(it)]))               
    result.put(OpCode.CALLDATASIZE,  Triple.of(new UnsignedByte(0x36), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [EnvironmentalInformation::CALLDATASIZE(it)]))               
    result.put(OpCode.CALLDATACOPY,  Triple.of(new UnsignedByte(0x37), Pair.of(new UnsignedByte(3),  new UnsignedByte(0)),  [EnvironmentalInformation::CALLDATACOPY(it)]))               
    result.put(OpCode.CODESIZE,      Triple.of(new UnsignedByte(0x38), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [EnvironmentalInformation::CODESIZE(it)]))               
    result.put(OpCode.CODECOPY,      Triple.of(new UnsignedByte(0x39), Pair.of(new UnsignedByte(3),  new UnsignedByte(0)),  [EnvironmentalInformation::CODECOPY(it)]))               
    result.put(OpCode.GASPRICE,      Triple.of(new UnsignedByte(0x3A), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [EnvironmentalInformation::GASPRICE(it)]))               
    result.put(OpCode.EXTCODESIZE,   Triple.of(new UnsignedByte(0x3B), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [EnvironmentalInformation::EXTCODESIZE(it)]))               
    result.put(OpCode.EXTCODECOPY,   Triple.of(new UnsignedByte(0x3C), Pair.of(new UnsignedByte(4),  new UnsignedByte(0)),  [EnvironmentalInformation::EXTCODECOPY(it)]))               
    result.put(OpCode.BLOCKHASH,     Triple.of(new UnsignedByte(0x40), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [BlockInformation::BLOCKHASH(it)]))               
    result.put(OpCode.COINBASE,      Triple.of(new UnsignedByte(0x41), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [BlockInformation::COINBASE(it)]))               
    result.put(OpCode.TIMESTAMP,     Triple.of(new UnsignedByte(0x42), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [BlockInformation::TIMESTAMP(it)]))               
    result.put(OpCode.NUMBER,        Triple.of(new UnsignedByte(0x43), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [BlockInformation::NUMBER(it)]))               
    result.put(OpCode.DIFFICULTY,    Triple.of(new UnsignedByte(0x44), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [BlockInformation::DIFFICULTY(it)]))               
    result.put(OpCode.GASLIMIT,      Triple.of(new UnsignedByte(0x45), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [BlockInformation::GASLIMIT(it)]))               
    result.put(OpCode.POP,           Triple.of(new UnsignedByte(0x50), Pair.of(new UnsignedByte(1),  new UnsignedByte(0)),  [StackMemoryStorageAndFlowOperations::POP(it)]))               
    result.put(OpCode.MLOAD,         Triple.of(new UnsignedByte(0x51), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [StackMemoryStorageAndFlowOperations::MLOAD(it)]))               
    result.put(OpCode.MSTORE,        Triple.of(new UnsignedByte(0x52), Pair.of(new UnsignedByte(2),  new UnsignedByte(0)),  [StackMemoryStorageAndFlowOperations::MSTORE(it)]))               
    result.put(OpCode.MSTORE8,       Triple.of(new UnsignedByte(0x53), Pair.of(new UnsignedByte(2),  new UnsignedByte(0)),  [StackMemoryStorageAndFlowOperations::MSTORE8(it)]))               
    result.put(OpCode.SLOAD,         Triple.of(new UnsignedByte(0x54), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [StackMemoryStorageAndFlowOperations::SLOAD(it)]))               
    result.put(OpCode.SSTORE,        Triple.of(new UnsignedByte(0x55), Pair.of(new UnsignedByte(2),  new UnsignedByte(0)),  [StackMemoryStorageAndFlowOperations::SSTORE(it)]))               
    result.put(OpCode.JUMP,          Triple.of(new UnsignedByte(0x56), Pair.of(new UnsignedByte(1),  new UnsignedByte(0)),  [StackMemoryStorageAndFlowOperations::JUMP(it)]))               
    result.put(OpCode.JUMPI,         Triple.of(new UnsignedByte(0x57), Pair.of(new UnsignedByte(2),  new UnsignedByte(0)),  [StackMemoryStorageAndFlowOperations::JUMPI(it)]))               
    result.put(OpCode.PC,            Triple.of(new UnsignedByte(0x58), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [StackMemoryStorageAndFlowOperations::PC(it)]))               
    result.put(OpCode.MSIZE,         Triple.of(new UnsignedByte(0x59), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [StackMemoryStorageAndFlowOperations::MSIZE(it)]))               
    result.put(OpCode.GAS,           Triple.of(new UnsignedByte(0x5A), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [StackMemoryStorageAndFlowOperations::GAS(it)]))               
    result.put(OpCode.JUMPDEST,      Triple.of(new UnsignedByte(0x5B), Pair.of(new UnsignedByte(0),  new UnsignedByte(0)),  [StackMemoryStorageAndFlowOperations::JUMPDEST(it)]))    
    result.put(OpCode.PUSH1,         Triple.of(new UnsignedByte(0x60), Pair.of(new UnsignedByte(0),  new UnsignedByte(1)),  [PushOperations::PUSHN(1, it)]))               
    result.put(OpCode.PUSH2,         Triple.of(new UnsignedByte(0x61), Pair.of(new UnsignedByte(1),  new UnsignedByte(1)),  [PushOperations::PUSHN(2, it)]))               
    result.put(OpCode.PUSH3,         Triple.of(new UnsignedByte(0x62), Pair.of(new UnsignedByte(2),  new UnsignedByte(1)),  [PushOperations::PUSHN(3, it)]))               
    result.put(OpCode.PUSH4,         Triple.of(new UnsignedByte(0x63), Pair.of(new UnsignedByte(3),  new UnsignedByte(1)),  [PushOperations::PUSHN(4, it)]))               
    result.put(OpCode.PUSH5,         Triple.of(new UnsignedByte(0x64), Pair.of(new UnsignedByte(4),  new UnsignedByte(1)),  [PushOperations::PUSHN(5, it)]))               
    result.put(OpCode.PUSH6,         Triple.of(new UnsignedByte(0x65), Pair.of(new UnsignedByte(5),  new UnsignedByte(1)),  [PushOperations::PUSHN(6, it)]))               
    result.put(OpCode.PUSH7,         Triple.of(new UnsignedByte(0x66), Pair.of(new UnsignedByte(6),  new UnsignedByte(1)),  [PushOperations::PUSHN(7, it)]))               
    result.put(OpCode.PUSH8,         Triple.of(new UnsignedByte(0x67), Pair.of(new UnsignedByte(7),  new UnsignedByte(1)),  [PushOperations::PUSHN(8, it)]))               
    result.put(OpCode.PUSH9,         Triple.of(new UnsignedByte(0x68), Pair.of(new UnsignedByte(8),  new UnsignedByte(1)),  [PushOperations::PUSHN(9, it)]))               
    result.put(OpCode.PUSH10,        Triple.of(new UnsignedByte(0x69), Pair.of(new UnsignedByte(9),  new UnsignedByte(1)),  [PushOperations::PUSHN(10, it)]))               
    result.put(OpCode.PUSH11,        Triple.of(new UnsignedByte(0x6A), Pair.of(new UnsignedByte(10), new UnsignedByte(1)),  [PushOperations::PUSHN(11, it)]))               
    result.put(OpCode.PUSH12,        Triple.of(new UnsignedByte(0x6B), Pair.of(new UnsignedByte(11), new UnsignedByte(1)),  [PushOperations::PUSHN(12, it)]))               
    result.put(OpCode.PUSH13,        Triple.of(new UnsignedByte(0x6C), Pair.of(new UnsignedByte(12), new UnsignedByte(1)),  [PushOperations::PUSHN(13, it)]))               
    result.put(OpCode.PUSH14,        Triple.of(new UnsignedByte(0x6D), Pair.of(new UnsignedByte(13), new UnsignedByte(1)),  [PushOperations::PUSHN(14, it)]))               
    result.put(OpCode.PUSH15,        Triple.of(new UnsignedByte(0x6E), Pair.of(new UnsignedByte(14), new UnsignedByte(1)),  [PushOperations::PUSHN(15, it)]))               
    result.put(OpCode.PUSH16,        Triple.of(new UnsignedByte(0x6F), Pair.of(new UnsignedByte(15), new UnsignedByte(1)),  [PushOperations::PUSHN(16, it)]))               
    result.put(OpCode.PUSH17,        Triple.of(new UnsignedByte(0x70), Pair.of(new UnsignedByte(16), new UnsignedByte(1)),  [PushOperations::PUSHN(17, it)]))               
    result.put(OpCode.PUSH18,        Triple.of(new UnsignedByte(0x71), Pair.of(new UnsignedByte(17), new UnsignedByte(1)),  [PushOperations::PUSHN(18, it)]))               
    result.put(OpCode.PUSH19,        Triple.of(new UnsignedByte(0x72), Pair.of(new UnsignedByte(18), new UnsignedByte(1)),  [PushOperations::PUSHN(19, it)]))               
    result.put(OpCode.PUSH20,        Triple.of(new UnsignedByte(0x73), Pair.of(new UnsignedByte(19), new UnsignedByte(1)),  [PushOperations::PUSHN(20, it)]))               
    result.put(OpCode.PUSH21,        Triple.of(new UnsignedByte(0x74), Pair.of(new UnsignedByte(20), new UnsignedByte(1)),  [PushOperations::PUSHN(21, it)]))               
    result.put(OpCode.PUSH22,        Triple.of(new UnsignedByte(0x75), Pair.of(new UnsignedByte(21), new UnsignedByte(1)),  [PushOperations::PUSHN(22, it)]))               
    result.put(OpCode.PUSH23,        Triple.of(new UnsignedByte(0x76), Pair.of(new UnsignedByte(22), new UnsignedByte(1)),  [PushOperations::PUSHN(23, it)]))               
    result.put(OpCode.PUSH24,        Triple.of(new UnsignedByte(0x77), Pair.of(new UnsignedByte(23), new UnsignedByte(1)),  [PushOperations::PUSHN(24, it)]))               
    result.put(OpCode.PUSH25,        Triple.of(new UnsignedByte(0x78), Pair.of(new UnsignedByte(24), new UnsignedByte(1)),  [PushOperations::PUSHN(25, it)]))               
    result.put(OpCode.PUSH26,        Triple.of(new UnsignedByte(0x79), Pair.of(new UnsignedByte(25), new UnsignedByte(1)),  [PushOperations::PUSHN(26, it)]))               
    result.put(OpCode.PUSH27,        Triple.of(new UnsignedByte(0x7A), Pair.of(new UnsignedByte(26), new UnsignedByte(1)),  [PushOperations::PUSHN(27, it)]))               
    result.put(OpCode.PUSH28,        Triple.of(new UnsignedByte(0x7B), Pair.of(new UnsignedByte(27), new UnsignedByte(1)),  [PushOperations::PUSHN(28, it)]))               
    result.put(OpCode.PUSH29,        Triple.of(new UnsignedByte(0x7C), Pair.of(new UnsignedByte(28), new UnsignedByte(1)),  [PushOperations::PUSHN(29, it)]))               
    result.put(OpCode.PUSH30,        Triple.of(new UnsignedByte(0x7D), Pair.of(new UnsignedByte(29), new UnsignedByte(1)),  [PushOperations::PUSHN(30, it)]))               
    result.put(OpCode.PUSH31,        Triple.of(new UnsignedByte(0x7E), Pair.of(new UnsignedByte(30), new UnsignedByte(1)),  [PushOperations::PUSHN(31, it)]))               
    result.put(OpCode.PUSH32,        Triple.of(new UnsignedByte(0x7F), Pair.of(new UnsignedByte(31), new UnsignedByte(1)),  [PushOperations::PUSHN(32, it)]))               
    result.put(OpCode.DUP1,          Triple.of(new UnsignedByte(0x80), Pair.of(new UnsignedByte(1),  new UnsignedByte(2)),  [DuplicationOperations::DUPN(1, it)]))            
    result.put(OpCode.DUP2,          Triple.of(new UnsignedByte(0x81), Pair.of(new UnsignedByte(2),  new UnsignedByte(3)),  [DuplicationOperations::DUPN(2, it)]))            
    result.put(OpCode.DUP3,          Triple.of(new UnsignedByte(0x82), Pair.of(new UnsignedByte(3),  new UnsignedByte(4)),  [DuplicationOperations::DUPN(3, it)]))            
    result.put(OpCode.DUP4,          Triple.of(new UnsignedByte(0x83), Pair.of(new UnsignedByte(4),  new UnsignedByte(5)),  [DuplicationOperations::DUPN(4, it)]))            
    result.put(OpCode.DUP5,          Triple.of(new UnsignedByte(0x84), Pair.of(new UnsignedByte(5),  new UnsignedByte(6)),  [DuplicationOperations::DUPN(5, it)]))            
    result.put(OpCode.DUP6,          Triple.of(new UnsignedByte(0x85), Pair.of(new UnsignedByte(6),  new UnsignedByte(7)),  [DuplicationOperations::DUPN(6, it)]))            
    result.put(OpCode.DUP7,          Triple.of(new UnsignedByte(0x86), Pair.of(new UnsignedByte(7),  new UnsignedByte(8)),  [DuplicationOperations::DUPN(7, it)]))            
    result.put(OpCode.DUP8,          Triple.of(new UnsignedByte(0x87), Pair.of(new UnsignedByte(8),  new UnsignedByte(9)),  [DuplicationOperations::DUPN(8, it)]))            
    result.put(OpCode.DUP9,          Triple.of(new UnsignedByte(0x88), Pair.of(new UnsignedByte(9),  new UnsignedByte(10)), [DuplicationOperations::DUPN(9, it)]))           
    result.put(OpCode.DUP10,         Triple.of(new UnsignedByte(0x89), Pair.of(new UnsignedByte(10), new UnsignedByte(11)), [DuplicationOperations::DUPN(10, it)]))           
    result.put(OpCode.DUP11,         Triple.of(new UnsignedByte(0x8A), Pair.of(new UnsignedByte(11), new UnsignedByte(12)), [DuplicationOperations::DUPN(11, it)]))           
    result.put(OpCode.DUP12,         Triple.of(new UnsignedByte(0x8B), Pair.of(new UnsignedByte(12), new UnsignedByte(13)), [DuplicationOperations::DUPN(12, it)]))           
    result.put(OpCode.DUP13,         Triple.of(new UnsignedByte(0x8C), Pair.of(new UnsignedByte(13), new UnsignedByte(14)), [DuplicationOperations::DUPN(13, it)]))           
    result.put(OpCode.DUP14,         Triple.of(new UnsignedByte(0x8D), Pair.of(new UnsignedByte(14), new UnsignedByte(15)), [DuplicationOperations::DUPN(14, it)]))           
    result.put(OpCode.DUP15,         Triple.of(new UnsignedByte(0x8E), Pair.of(new UnsignedByte(15), new UnsignedByte(16)), [DuplicationOperations::DUPN(15, it)]))           
    result.put(OpCode.DUP16,         Triple.of(new UnsignedByte(0x8F), Pair.of(new UnsignedByte(16), new UnsignedByte(17)), [DuplicationOperations::DUPN(16, it)]))           
    result.put(OpCode.SWAP1,         Triple.of(new UnsignedByte(0x90), Pair.of(new UnsignedByte(2),  new UnsignedByte(2)),  [ExchangeOperations::SWAPN(1, it)]))         
    result.put(OpCode.SWAP2,         Triple.of(new UnsignedByte(0x91), Pair.of(new UnsignedByte(3),  new UnsignedByte(3)),  [ExchangeOperations::SWAPN(2, it)]))         
    result.put(OpCode.SWAP3,         Triple.of(new UnsignedByte(0x92), Pair.of(new UnsignedByte(4),  new UnsignedByte(4)),  [ExchangeOperations::SWAPN(3, it)]))         
    result.put(OpCode.SWAP4,         Triple.of(new UnsignedByte(0x93), Pair.of(new UnsignedByte(5),  new UnsignedByte(5)),  [ExchangeOperations::SWAPN(4, it)]))         
    result.put(OpCode.SWAP5,         Triple.of(new UnsignedByte(0x94), Pair.of(new UnsignedByte(6),  new UnsignedByte(6)),  [ExchangeOperations::SWAPN(5, it)]))         
    result.put(OpCode.SWAP6,         Triple.of(new UnsignedByte(0x95), Pair.of(new UnsignedByte(7),  new UnsignedByte(7)),  [ExchangeOperations::SWAPN(6, it)]))         
    result.put(OpCode.SWAP7,         Triple.of(new UnsignedByte(0x96), Pair.of(new UnsignedByte(8),  new UnsignedByte(8)),  [ExchangeOperations::SWAPN(7, it)]))         
    result.put(OpCode.SWAP8,         Triple.of(new UnsignedByte(0x97), Pair.of(new UnsignedByte(9),  new UnsignedByte(9)),  [ExchangeOperations::SWAPN(8, it)]))         
    result.put(OpCode.SWAP9,         Triple.of(new UnsignedByte(0x98), Pair.of(new UnsignedByte(10), new UnsignedByte(10)), [ExchangeOperations::SWAPN(9, it)]))         
    result.put(OpCode.SWAP10,        Triple.of(new UnsignedByte(0x99), Pair.of(new UnsignedByte(11), new UnsignedByte(11)), [ExchangeOperations::SWAPN(10, it)]))        
    result.put(OpCode.SWAP11,        Triple.of(new UnsignedByte(0x9A), Pair.of(new UnsignedByte(12), new UnsignedByte(12)), [ExchangeOperations::SWAPN(11, it)]))         
    result.put(OpCode.SWAP12,        Triple.of(new UnsignedByte(0x9B), Pair.of(new UnsignedByte(13), new UnsignedByte(13)), [ExchangeOperations::SWAPN(12, it)]))         
    result.put(OpCode.SWAP13,        Triple.of(new UnsignedByte(0x9C), Pair.of(new UnsignedByte(14), new UnsignedByte(14)), [ExchangeOperations::SWAPN(13, it)]))         
    result.put(OpCode.SWAP14,        Triple.of(new UnsignedByte(0x9D), Pair.of(new UnsignedByte(15), new UnsignedByte(15)), [ExchangeOperations::SWAPN(14, it)]))         
    result.put(OpCode.SWAP15,        Triple.of(new UnsignedByte(0x9E), Pair.of(new UnsignedByte(16), new UnsignedByte(16)), [ExchangeOperations::SWAPN(15, it)]))         
    result.put(OpCode.SWAP16,        Triple.of(new UnsignedByte(0x9F), Pair.of(new UnsignedByte(17), new UnsignedByte(17)), [ExchangeOperations::SWAPN(16, it)]))
    result.put(OpCode.LOG0,          Triple.of(new UnsignedByte(0xA0), Pair.of(new UnsignedByte(2),  new UnsignedByte(0)),  [LoggingOperations::LOGN(0, it)]))
    result.put(OpCode.LOG1,          Triple.of(new UnsignedByte(0xA1), Pair.of(new UnsignedByte(3),  new UnsignedByte(0)),  [LoggingOperations::LOGN(1, it)]))
    result.put(OpCode.LOG2,          Triple.of(new UnsignedByte(0xA2), Pair.of(new UnsignedByte(4),  new UnsignedByte(0)),  [LoggingOperations::LOGN(2, it)]))
    result.put(OpCode.LOG3,          Triple.of(new UnsignedByte(0xA3), Pair.of(new UnsignedByte(5),  new UnsignedByte(0)),  [LoggingOperations::LOGN(3, it)]))
    result.put(OpCode.LOG4,          Triple.of(new UnsignedByte(0xA4), Pair.of(new UnsignedByte(6),  new UnsignedByte(0)),  [LoggingOperations::LOGN(4, it)]))
    result.put(OpCode.CREATE,        Triple.of(new UnsignedByte(0xF0), Pair.of(new UnsignedByte(3),  new UnsignedByte(1)),  [SystemOperations::CREATE(it)]))
    result.put(OpCode.CALL,          Triple.of(new UnsignedByte(0xF1), Pair.of(new UnsignedByte(7),  new UnsignedByte(1)),  [SystemOperations::CALL(it)]))
    result.put(OpCode.CALLCODE,      Triple.of(new UnsignedByte(0xF2), Pair.of(new UnsignedByte(7),  new UnsignedByte(1)),  [SystemOperations::CALLCODE(it)]))
    result.put(OpCode.RETURN,        Triple.of(new UnsignedByte(0xF3), Pair.of(new UnsignedByte(2),  new UnsignedByte(0)),  [SystemOperations::RETURN(it)]))
    result.put(OpCode.DELEGATECALL,  Triple.of(new UnsignedByte(0xF4), Pair.of(new UnsignedByte(6),  new UnsignedByte(1)),  [SystemOperations::DELEGATECALL(it)]))
    result.put(OpCode.INVALID,       Triple.of(new UnsignedByte(0xFE), Pair.of(new UnsignedByte(0),  new UnsignedByte(0)),  [SystemOperations::INVALID(it)]))
    result.put(OpCode.SELFDESTRUCT,  Triple.of(new UnsignedByte(0xFF), Pair.of(new UnsignedByte(1),  new UnsignedByte(0)),  [SystemOperations::SELFDESTRUCT(it)]))
    result
  }
  
  def public static OpCode getOp(UnsignedByte opValue) {
    for (o : org.itemis.evm.EVMOperation.OP_INFO.entrySet) {
      if (o.value.left.equals(opValue)) {
        return o.key
      }
    }
    return OpCode.INVALID
  }
  
  def public static Triple<UnsignedByte, Pair<UnsignedByte, UnsignedByte>, Consumer<EVMRuntime>> getOpInfo(OpCode opCode) {
    OP_INFO.get(opCode)
  }
  
  def public static int getParameterCount(OpCode opCode) {
    switch opCode {
      case PUSH1: 1
      case PUSH2: 2
      case PUSH3: 3
      case PUSH4: 4
      case PUSH5: 5
      case PUSH6: 6
      case PUSH7: 7
      case PUSH8: 8
      case PUSH9: 9
      case PUSH10: 10
      case PUSH11: 11
      case PUSH12: 12
      case PUSH13: 13
      case PUSH14: 14
      case PUSH15: 15
      case PUSH16: 16
      case PUSH17: 17
      case PUSH18: 18
      case PUSH19: 19
      case PUSH20: 20
      case PUSH21: 21
      case PUSH22: 22
      case PUSH23: 23
      case PUSH24: 24
      case PUSH25: 25
      case PUSH26: 26
      case PUSH27: 27
      case PUSH28: 28
      case PUSH29: 29
      case PUSH30: 30
      case PUSH31: 31
      case PUSH32: 32
      default: 0
    }
  }
  
  def public static void executeOp(OpCode opCode, EVMRuntime runtime) {
    opCode.opInfo.right.accept(runtime)
  }
  
  public static enum FeeClass {
    ZERO,
    BASE,
    VERYLOW,
    LOW,
    MID,
    HIGH,
    EXTCODE,
    BALANCE,
    SLOAD,
    JUMPDEST,
    SSET,
    SRESET,
    SCLEAR_R,
    SELFDESTRUCT_R,
    SELFDESTRUCT,
    CREATE,
    CODEDEPOSIT,
    CALL,
    CALLVALUE,
    CALLSTIPEND,
    NEWACCOUNT,
    EXP,
    EXPBYTE,
    MEMORY,
    TXCREATE,
    TXDATAZERO,
    TXDATANONZERO,
    TRANSACTION,
    LOG,
    LOGDATA,
    LOGTOPIC,
    SHA3,
    SHA3WORD,
    COPY,
    BLOCKHASH
  }
  
  public static final EnumMap<FeeClass, EVMWord> FEE_SCHEDULE = {
    val result = new EnumMap(FeeClass)
    result.put(FeeClass.ZERO          , EVMWord.ZERO)
    result.put(FeeClass.BASE          , new EVMWord(    2))
    result.put(FeeClass.VERYLOW       , new EVMWord(    3))
    result.put(FeeClass.LOW           , new EVMWord(    5))
    result.put(FeeClass.MID           , new EVMWord(    8))
    result.put(FeeClass.HIGH          , new EVMWord(   10))
    result.put(FeeClass.EXTCODE       , new EVMWord(  700))
    result.put(FeeClass.BALANCE       , new EVMWord(  400))
    result.put(FeeClass.SLOAD         , new EVMWord(  200))
    result.put(FeeClass.JUMPDEST      , new EVMWord(    1))
    result.put(FeeClass.SSET          , new EVMWord(20000))
    result.put(FeeClass.SRESET        , new EVMWord( 5000))
    result.put(FeeClass.SCLEAR_R      , new EVMWord(15000))
    result.put(FeeClass.SELFDESTRUCT_R, new EVMWord(24000))
    result.put(FeeClass.SELFDESTRUCT  , new EVMWord( 5000))
    result.put(FeeClass.CREATE        , new EVMWord(32000))
    result.put(FeeClass.CODEDEPOSIT   , new EVMWord(  200))
    result.put(FeeClass.CALL          , new EVMWord(  700))
    result.put(FeeClass.CALLVALUE     , new EVMWord( 9000))
    result.put(FeeClass.CALLSTIPEND   , new EVMWord( 2300))
    result.put(FeeClass.NEWACCOUNT    , new EVMWord(25000))
    result.put(FeeClass.EXP           , new EVMWord(   10))
    result.put(FeeClass.EXPBYTE       , new EVMWord(   50))
    result.put(FeeClass.MEMORY        , new EVMWord(    3))
    result.put(FeeClass.TXCREATE      , new EVMWord(32000))
    result.put(FeeClass.TXDATAZERO    , new EVMWord(    4))
    result.put(FeeClass.TXDATANONZERO , new EVMWord(   68))
    result.put(FeeClass.TRANSACTION   , new EVMWord(21000))
    result.put(FeeClass.LOG           , new EVMWord(  375))
    result.put(FeeClass.LOGDATA       , new EVMWord(    8))
    result.put(FeeClass.LOGTOPIC      , new EVMWord(  375))
    result.put(FeeClass.SHA3          , new EVMWord(   30))
    result.put(FeeClass.SHA3WORD      , new EVMWord(    6))
    result.put(FeeClass.COPY          , new EVMWord(    3))
    result.put(FeeClass.BLOCKHASH     , new EVMWord(   20))
    result
  }
}