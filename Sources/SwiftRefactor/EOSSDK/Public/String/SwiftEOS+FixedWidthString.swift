
import Foundation

public protocol SizeType {
    static var size: Int { get }
}

public struct FixedWidthString<Size: SizeType>: Equatable {

    public static var zero: FixedWidthString {
        .init(buffer: .init(repeating: .zero, count: Size.size))
    }

    private let buffer: ContiguousArray<CChar>

    private init(buffer: ContiguousArray<CChar>) {
        self.buffer = buffer
    }

    public init(_ string: String) {
        var buffer = string.utf8CString.prefix(Size.size)
        buffer.append(contentsOf: Array(repeating: .zero, count: Size.size - buffer.count))
        buffer[buffer.count - 1] = 0
        assert(buffer.count == Size.size)
        self.buffer = ContiguousArray(buffer)
    }

    public init<TupleType>(tuple value: TupleType) {
        assert(MemoryLayout<TupleType>.size == Size.size)
        self.buffer = withUnsafeBytes(of: value) { pointer in
            assert(MemoryLayout<TupleType>.size == pointer.count)
            guard let charPointer = pointer.baseAddress?.assumingMemoryBound(to: CChar.self) else {
                return ContiguousArray<CChar>(repeating: .zero, count: Size.size)
            }
            return ContiguousArray<CChar>(UnsafeBufferPointer(start: charPointer, count: Size.size))
        }
    }

    public func tuple<TupleType>() -> TupleType {
        buffer.withUnsafeBytes { ptr in
            assert(MemoryLayout<TupleType>.size == Size.size)
            assert(MemoryLayout<TupleType>.size == ptr.count)
            return ptr.load(as: TupleType.self)
        }
    }
}

// TODO: emit
public enum Size_33: SizeType {
    public static let size: Int = 33
}

// TODO: emit
public typealias String_33 = FixedWidthString<Size_33>
