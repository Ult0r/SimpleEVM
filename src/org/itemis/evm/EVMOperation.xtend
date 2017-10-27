package org.itemis.evm

import org.itemis.types.UnsignedByte
import java.util.EnumMap
import org.apache.commons.lang3.tuple.Triple
import org.itemis.evm.utils.Patch
import org.itemis.types.EVMWord

abstract class EVMOperation {
  public static enum OpCode {
    STOP,
    ADD,
    MUL,
    SUB,
    DIV,
    SDVI,
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
    MSTORES,
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
  public static final EnumMap<OpCode, Triple<UnsignedByte, UnsignedByte, UnsignedByte>> OP_VALUES = {
    val result = new EnumMap(OpCode)
    result.put(OpCode.STOP,          Triple.of(new UnsignedByte(0x00), new UnsignedByte(0),  new UnsignedByte(0)))           
    result.put(OpCode.ADD,           Triple.of(new UnsignedByte(0x01), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.MUL,           Triple.of(new UnsignedByte(0x02), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.SUB,           Triple.of(new UnsignedByte(0x03), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.DIV,           Triple.of(new UnsignedByte(0x04), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.SDVI,          Triple.of(new UnsignedByte(0x05), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.MOD,           Triple.of(new UnsignedByte(0x06), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.SMOD,          Triple.of(new UnsignedByte(0x07), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.ADDMOD,        Triple.of(new UnsignedByte(0x08), new UnsignedByte(3),  new UnsignedByte(1)))               
    result.put(OpCode.MULMOD,        Triple.of(new UnsignedByte(0x09), new UnsignedByte(3),  new UnsignedByte(1)))               
    result.put(OpCode.EXP,           Triple.of(new UnsignedByte(0x0A), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.SIGNEXTEND,    Triple.of(new UnsignedByte(0x0B), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.LT,            Triple.of(new UnsignedByte(0x10), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.GT,            Triple.of(new UnsignedByte(0x11), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.SLT,           Triple.of(new UnsignedByte(0x12), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.SGT,           Triple.of(new UnsignedByte(0x13), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.EQ,            Triple.of(new UnsignedByte(0x14), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.ISZERO,        Triple.of(new UnsignedByte(0x15), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.AND,           Triple.of(new UnsignedByte(0x16), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.OR,            Triple.of(new UnsignedByte(0x17), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.XOR,           Triple.of(new UnsignedByte(0x18), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.NOT,           Triple.of(new UnsignedByte(0x19), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.BYTE,          Triple.of(new UnsignedByte(0x1A), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.SHA3,          Triple.of(new UnsignedByte(0x20), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.ADDRESS,       Triple.of(new UnsignedByte(0x30), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.BALANCE,       Triple.of(new UnsignedByte(0x31), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.ORIGIN,        Triple.of(new UnsignedByte(0x32), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.CALLER,        Triple.of(new UnsignedByte(0x33), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.CALLVALUE,     Triple.of(new UnsignedByte(0x34), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.CALLDATALOAD,  Triple.of(new UnsignedByte(0x35), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.CALLDATASIZE,  Triple.of(new UnsignedByte(0x36), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.CALLDATACOPY,  Triple.of(new UnsignedByte(0x37), new UnsignedByte(3),  new UnsignedByte(0)))               
    result.put(OpCode.CODESIZE,      Triple.of(new UnsignedByte(0x38), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.CODECOPY,      Triple.of(new UnsignedByte(0x39), new UnsignedByte(3),  new UnsignedByte(0)))               
    result.put(OpCode.GASPRICE,      Triple.of(new UnsignedByte(0x3A), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.EXTCODESIZE,   Triple.of(new UnsignedByte(0x3B), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.EXTCODECOPY,   Triple.of(new UnsignedByte(0x3C), new UnsignedByte(4),  new UnsignedByte(0)))               
    result.put(OpCode.BLOCKHASH,     Triple.of(new UnsignedByte(0x40), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.COINBASE,      Triple.of(new UnsignedByte(0x41), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.TIMESTAMP,     Triple.of(new UnsignedByte(0x42), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.NUMBER,        Triple.of(new UnsignedByte(0x43), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.DIFFICULTY,    Triple.of(new UnsignedByte(0x44), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.GASLIMIT,      Triple.of(new UnsignedByte(0x45), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.POP,           Triple.of(new UnsignedByte(0x50), new UnsignedByte(1),  new UnsignedByte(0)))               
    result.put(OpCode.MLOAD,         Triple.of(new UnsignedByte(0x51), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.MSTORE,        Triple.of(new UnsignedByte(0x52), new UnsignedByte(2),  new UnsignedByte(0)))               
    result.put(OpCode.MSTORES,       Triple.of(new UnsignedByte(0x53), new UnsignedByte(2),  new UnsignedByte(0)))               
    result.put(OpCode.SLOAD,         Triple.of(new UnsignedByte(0x54), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.SSTORE,        Triple.of(new UnsignedByte(0x55), new UnsignedByte(2),  new UnsignedByte(0)))               
    result.put(OpCode.JUMP,          Triple.of(new UnsignedByte(0x56), new UnsignedByte(1),  new UnsignedByte(0)))               
    result.put(OpCode.JUMPI,         Triple.of(new UnsignedByte(0x57), new UnsignedByte(2),  new UnsignedByte(0)))               
    result.put(OpCode.PC,            Triple.of(new UnsignedByte(0x58), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.MSIZE,         Triple.of(new UnsignedByte(0x59), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.GAS,           Triple.of(new UnsignedByte(0x5A), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.JUMPDEST,      Triple.of(new UnsignedByte(0x5B), new UnsignedByte(0),  new UnsignedByte(0)))               
    result.put(OpCode.PUSH1,         Triple.of(new UnsignedByte(0x60), new UnsignedByte(0),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH2,         Triple.of(new UnsignedByte(0x61), new UnsignedByte(1),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH3,         Triple.of(new UnsignedByte(0x62), new UnsignedByte(2),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH4,         Triple.of(new UnsignedByte(0x63), new UnsignedByte(3),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH5,         Triple.of(new UnsignedByte(0x64), new UnsignedByte(4),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH6,         Triple.of(new UnsignedByte(0x65), new UnsignedByte(5),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH7,         Triple.of(new UnsignedByte(0x66), new UnsignedByte(6),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH8,         Triple.of(new UnsignedByte(0x67), new UnsignedByte(7),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH9,         Triple.of(new UnsignedByte(0x68), new UnsignedByte(8),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH10,        Triple.of(new UnsignedByte(0x69), new UnsignedByte(9),  new UnsignedByte(1)))               
    result.put(OpCode.PUSH11,        Triple.of(new UnsignedByte(0x6A), new UnsignedByte(10), new UnsignedByte(1)))               
    result.put(OpCode.PUSH12,        Triple.of(new UnsignedByte(0x6B), new UnsignedByte(11), new UnsignedByte(1)))               
    result.put(OpCode.PUSH13,        Triple.of(new UnsignedByte(0x6C), new UnsignedByte(12), new UnsignedByte(1)))               
    result.put(OpCode.PUSH14,        Triple.of(new UnsignedByte(0x6D), new UnsignedByte(13), new UnsignedByte(1)))               
    result.put(OpCode.PUSH15,        Triple.of(new UnsignedByte(0x6E), new UnsignedByte(14), new UnsignedByte(1)))               
    result.put(OpCode.PUSH16,        Triple.of(new UnsignedByte(0x6F), new UnsignedByte(15), new UnsignedByte(1)))               
    result.put(OpCode.PUSH17,        Triple.of(new UnsignedByte(0x70), new UnsignedByte(16), new UnsignedByte(1)))               
    result.put(OpCode.PUSH18,        Triple.of(new UnsignedByte(0x71), new UnsignedByte(17), new UnsignedByte(1)))               
    result.put(OpCode.PUSH19,        Triple.of(new UnsignedByte(0x72), new UnsignedByte(18), new UnsignedByte(1)))               
    result.put(OpCode.PUSH20,        Triple.of(new UnsignedByte(0x73), new UnsignedByte(19), new UnsignedByte(1)))               
    result.put(OpCode.PUSH21,        Triple.of(new UnsignedByte(0x74), new UnsignedByte(20), new UnsignedByte(1)))               
    result.put(OpCode.PUSH22,        Triple.of(new UnsignedByte(0x75), new UnsignedByte(21), new UnsignedByte(1)))               
    result.put(OpCode.PUSH23,        Triple.of(new UnsignedByte(0x76), new UnsignedByte(22), new UnsignedByte(1)))               
    result.put(OpCode.PUSH24,        Triple.of(new UnsignedByte(0x77), new UnsignedByte(23), new UnsignedByte(1)))               
    result.put(OpCode.PUSH25,        Triple.of(new UnsignedByte(0x78), new UnsignedByte(24), new UnsignedByte(1)))               
    result.put(OpCode.PUSH26,        Triple.of(new UnsignedByte(0x79), new UnsignedByte(25), new UnsignedByte(1)))               
    result.put(OpCode.PUSH27,        Triple.of(new UnsignedByte(0x7A), new UnsignedByte(26), new UnsignedByte(1)))               
    result.put(OpCode.PUSH28,        Triple.of(new UnsignedByte(0x7B), new UnsignedByte(27), new UnsignedByte(1)))               
    result.put(OpCode.PUSH29,        Triple.of(new UnsignedByte(0x7C), new UnsignedByte(28), new UnsignedByte(1)))               
    result.put(OpCode.PUSH30,        Triple.of(new UnsignedByte(0x7D), new UnsignedByte(29), new UnsignedByte(1)))               
    result.put(OpCode.PUSH31,        Triple.of(new UnsignedByte(0x7E), new UnsignedByte(30), new UnsignedByte(1)))               
    result.put(OpCode.PUSH32,        Triple.of(new UnsignedByte(0x7F), new UnsignedByte(31), new UnsignedByte(1)))               
    result.put(OpCode.DUP1,          Triple.of(new UnsignedByte(0x80), new UnsignedByte(1),  new UnsignedByte(2)))            
    result.put(OpCode.DUP2,          Triple.of(new UnsignedByte(0x81), new UnsignedByte(2),  new UnsignedByte(3)))            
    result.put(OpCode.DUP3,          Triple.of(new UnsignedByte(0x82), new UnsignedByte(3),  new UnsignedByte(4)))            
    result.put(OpCode.DUP4,          Triple.of(new UnsignedByte(0x83), new UnsignedByte(4),  new UnsignedByte(5)))            
    result.put(OpCode.DUP5,          Triple.of(new UnsignedByte(0x84), new UnsignedByte(5),  new UnsignedByte(6)))            
    result.put(OpCode.DUP6,          Triple.of(new UnsignedByte(0x85), new UnsignedByte(6),  new UnsignedByte(7)))            
    result.put(OpCode.DUP7,          Triple.of(new UnsignedByte(0x86), new UnsignedByte(7),  new UnsignedByte(8)))            
    result.put(OpCode.DUP8,          Triple.of(new UnsignedByte(0x87), new UnsignedByte(8),  new UnsignedByte(9)))            
    result.put(OpCode.DUP9,          Triple.of(new UnsignedByte(0x88), new UnsignedByte(9),  new UnsignedByte(10)))           
    result.put(OpCode.DUP10,         Triple.of(new UnsignedByte(0x89), new UnsignedByte(10), new UnsignedByte(11)))           
    result.put(OpCode.DUP11,         Triple.of(new UnsignedByte(0x8A), new UnsignedByte(11), new UnsignedByte(12)))           
    result.put(OpCode.DUP12,         Triple.of(new UnsignedByte(0x8B), new UnsignedByte(12), new UnsignedByte(13)))           
    result.put(OpCode.DUP13,         Triple.of(new UnsignedByte(0x8C), new UnsignedByte(13), new UnsignedByte(14)))           
    result.put(OpCode.DUP14,         Triple.of(new UnsignedByte(0x8D), new UnsignedByte(14), new UnsignedByte(15)))           
    result.put(OpCode.DUP15,         Triple.of(new UnsignedByte(0x8E), new UnsignedByte(15), new UnsignedByte(16)))           
    result.put(OpCode.DUP16,         Triple.of(new UnsignedByte(0x8F), new UnsignedByte(16), new UnsignedByte(17)))           
    result.put(OpCode.SWAP1,         Triple.of(new UnsignedByte(0x90), new UnsignedByte(2),  new UnsignedByte(2)))         
    result.put(OpCode.SWAP2,         Triple.of(new UnsignedByte(0x91), new UnsignedByte(3),  new UnsignedByte(3)))         
    result.put(OpCode.SWAP3,         Triple.of(new UnsignedByte(0x92), new UnsignedByte(4),  new UnsignedByte(4)))         
    result.put(OpCode.SWAP4,         Triple.of(new UnsignedByte(0x93), new UnsignedByte(5),  new UnsignedByte(5)))         
    result.put(OpCode.SWAP5,         Triple.of(new UnsignedByte(0x94), new UnsignedByte(6),  new UnsignedByte(6)))         
    result.put(OpCode.SWAP6,         Triple.of(new UnsignedByte(0x95), new UnsignedByte(7),  new UnsignedByte(7)))         
    result.put(OpCode.SWAP7,         Triple.of(new UnsignedByte(0x96), new UnsignedByte(8),  new UnsignedByte(8)))         
    result.put(OpCode.SWAP8,         Triple.of(new UnsignedByte(0x97), new UnsignedByte(9),  new UnsignedByte(9)))         
    result.put(OpCode.SWAP9,         Triple.of(new UnsignedByte(0x98), new UnsignedByte(10), new UnsignedByte(10)))         
    result.put(OpCode.SWAP10,        Triple.of(new UnsignedByte(0x99), new UnsignedByte(11), new UnsignedByte(11)))         
    result.put(OpCode.SWAP11,        Triple.of(new UnsignedByte(0x9A), new UnsignedByte(12), new UnsignedByte(12)))         
    result.put(OpCode.SWAP12,        Triple.of(new UnsignedByte(0x9B), new UnsignedByte(13), new UnsignedByte(13)))         
    result.put(OpCode.SWAP13,        Triple.of(new UnsignedByte(0x9C), new UnsignedByte(14), new UnsignedByte(14)))         
    result.put(OpCode.SWAP14,        Triple.of(new UnsignedByte(0x9D), new UnsignedByte(15), new UnsignedByte(15)))         
    result.put(OpCode.SWAP15,        Triple.of(new UnsignedByte(0x9E), new UnsignedByte(16), new UnsignedByte(16)))         
    result.put(OpCode.SWAP16,        Triple.of(new UnsignedByte(0x9F), new UnsignedByte(17), new UnsignedByte(17)))         
    result.put(OpCode.LOG0,          Triple.of(new UnsignedByte(0xA0), new UnsignedByte(2),  new UnsignedByte(0)))               
    result.put(OpCode.LOG1,          Triple.of(new UnsignedByte(0xA1), new UnsignedByte(3),  new UnsignedByte(0)))               
    result.put(OpCode.LOG2,          Triple.of(new UnsignedByte(0xA2), new UnsignedByte(4),  new UnsignedByte(0)))               
    result.put(OpCode.LOG3,          Triple.of(new UnsignedByte(0xA3), new UnsignedByte(5),  new UnsignedByte(0)))               
    result.put(OpCode.LOG4,          Triple.of(new UnsignedByte(0xA4), new UnsignedByte(6),  new UnsignedByte(0)))               
    result.put(OpCode.CREATE,        Triple.of(new UnsignedByte(0xF0), new UnsignedByte(3),  new UnsignedByte(1)))               
    result.put(OpCode.CALL,          Triple.of(new UnsignedByte(0xF1), new UnsignedByte(7),  new UnsignedByte(1)))               
    result.put(OpCode.CALLCODE,      Triple.of(new UnsignedByte(0xF2), new UnsignedByte(7),  new UnsignedByte(1)))               
    result.put(OpCode.RETURN,        Triple.of(new UnsignedByte(0xF3), new UnsignedByte(2),  new UnsignedByte(0)))               
    result.put(OpCode.DELEGATECALL,  Triple.of(new UnsignedByte(0xF4), new UnsignedByte(6),  new UnsignedByte(1)))               
    result.put(OpCode.INVALID,       Triple.of(new UnsignedByte(0xFE), new UnsignedByte(0),  new UnsignedByte(0)))               
    result.put(OpCode.SELFDESTRUCT,  Triple.of(new UnsignedByte(0xFF), new UnsignedByte(1),  new UnsignedByte(0))) 
    result
  }
  
  def public static OpCode getOp(UnsignedByte opValue) {
    for (o : OP_VALUES.entrySet) {
      if (o.value.left.equals(opValue)) {
        return o.key
      }
    }
    return OpCode.INVALID
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
    result.put(FeeClass.ZERO          , new EVMWord(    0))
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
  
  //<gasUsed, patch>
  def abstract Pair<EVMWord, Patch> execute(EVMRuntime runtime)
}