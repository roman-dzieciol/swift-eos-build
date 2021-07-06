
import Foundation

public class SwiftEOS__PointerManager {

    /** Closures called on `deinit` */
    private var onDeinit: [() -> Void]

    deinit {
        onDeinit.forEach { $0()}
    }

    public init() {
        self.onDeinit = []
    }

    public func onDeinit(_ closure: @escaping () -> Void) {
        onDeinit.append(closure)
    }

    public func managedMutablePointer<Pointee>(
        copyingValueOrUninitialized value: Pointee?
    ) -> UnsafeMutablePointer<Pointee> {

        let pointer = UnsafeMutablePointer<Pointee>.allocate(capacity: 1)
        defer {
            onDeinit {
                pointer.deallocate()
            }
        }

        if let value = value {
            pointer.initialize(to: value)
            onDeinit {
                pointer.deinitialize(count: 1)
            }
        }

        return pointer
    }

    public func managedMutablePointer<Pointee>(
        copyingValueOrNilPointer value: Pointee?
    ) -> Optional<UnsafeMutablePointer<Pointee>> {
        guard let value = value else { return nil }
        return managedMutablePointer(copyingValueOrUninitialized: value)
    }

    public func managedPointer<Pointee>(
        copyingValueOrNilPointer value: Pointee?
    ) -> Optional<UnsafePointer<Pointee>> {
        guard let value = value else { return nil }
        return UnsafePointer(managedMutablePointer(copyingValueOrNilPointer: value))
    }

    public func managedMutableBufferPointer<Element>(
        copyingArray source: Array<Element>?
    ) -> UnsafeMutableBufferPointer<Element>? {

        guard let source = source else { return nil }

        let bufferPointer = UnsafeMutableBufferPointer<Element>.allocate(capacity: source.count)
        defer {
            onDeinit {
                bufferPointer.deallocate()
            }
        }

        let (_, initializedCount) = bufferPointer.initialize(from: source)
        assert(initializedCount == source.count)
        onDeinit {
            bufferPointer.baseAddress?.deinitialize(count: initializedCount)
        }

        return bufferPointer
    }

    public func managedPointerToBuffer<Element>(
        copyingArray source: Array<Element>?
    ) -> UnsafePointer<Element>?  {
        guard let source = source else { return nil }
        return UnsafePointer(managedMutableBufferPointer(copyingArray: source)?.baseAddress)
    }

    public func managedPointerToBuffer<Element>(
        copyingArray source: ContiguousArray<Element>?
    ) -> UnsafePointer<Element>?  {
        guard let source = source else { return nil }
        return UnsafePointer(managedMutableBufferPointer(copyingArray: Array(source))?.baseAddress)
    }

    public func managedMutablePointerToBuffer<Element>(
        copyingArray source: Array<Element>?
    ) -> UnsafeMutablePointer<Element>?   {
        guard let source = source else { return nil }
        return managedMutableBufferPointer(copyingArray: source)?.baseAddress
    }

    public func managedMutablePointerToBuffer<Element>(
        copyingArray source: ContiguousArray<Element>?
    ) -> UnsafeMutablePointer<Element>?   {
        guard let source = source else { return nil }
        return managedMutableBufferPointer(copyingArray: Array(source))?.baseAddress
    }

    public func managedMutablePointerToBufferOfPointers<Element>(
        copyingArray source: Array<Array<Element>?>?
    ) -> UnsafeMutablePointer<UnsafePointer<Element>?>? {

        guard let source = source else { return nil }

        let pointersToCopies = source.map { element in
            UnsafePointer(managedMutableBufferPointer(copyingArray: element)?.baseAddress)
        }
        let bufferOfPointersToCopies = managedMutableBufferPointer(copyingArray: pointersToCopies)

        return UnsafeMutablePointer(bufferOfPointersToCopies?.baseAddress)
    }

    public func managedMutablePointerToBufferOfPointers<Element>(
        copyingArray source: Array<ContiguousArray<Element>?>?
    ) -> UnsafeMutablePointer<UnsafePointer<Element>?>? {

        guard let source = source else { return nil }

        let pointersToCopies = source
            .compactMap { $0 }
            .map { element in
                UnsafePointer(managedMutableBufferPointer(copyingArray: Array(element))?.baseAddress)
            }
        let bufferOfPointersToCopies = managedMutableBufferPointer(copyingArray: pointersToCopies)

        return UnsafeMutablePointer(bufferOfPointersToCopies?.baseAddress)
    }
}

public func withPointerManager<Result>(_ body: (_ pointerManager: SwiftEOS__PointerManager) throws -> Result) rethrows -> Result {
    return try withExtendedLifetime(SwiftEOS__PointerManager(), body)
}


