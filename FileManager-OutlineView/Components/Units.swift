//
//  Units.swift
//  FileManager-OutlineView
//
//  Created by Roy Rao on 2021/7/12.
//

import Foundation

public struct Units {
  
  public let bytes: UInt64
  
  public var kilobytes: Double {
    return Double(bytes) / 1_024
  }
  
  public var megabytes: Double {
    return kilobytes / 1_024
  }
  
  public var gigabytes: Double {
    return megabytes / 1_024
  }
  
  public init(_ bytes: UInt64) {
    self.bytes = bytes
  }
  
  public func getReadableUnit() -> String {
    
    switch bytes {
    case 0..<1_024:
      return "\(bytes) bytes"
    case 1_024..<(1_024 * 1_024):
      return "\(String(format: "%.2f", kilobytes)) KB"
    case 1_024..<(1_024 * 1_024 * 1_024):
      return "\(String(format: "%.2f", megabytes)) MB"
    case (1_024 * 1_024 * 1_024)...UInt64.max:
      return "\(String(format: "%.2f", gigabytes)) GB"
    default:
      return "\(bytes) bytes"
    }
  }
}
