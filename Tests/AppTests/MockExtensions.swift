//
//  MockExtensions.swift
//  aPrincipalEngineer
//
//  Created by Tyler Thompson on 12/9/24.
//

import Cuckoo
import DependencyInjection

extension Mock {
    func withStub(block: (Stubbing) -> Void) -> Self {
        block(getStubbingProxy())
        return self
    }
    
    @discardableResult func storeIn(_ container: SyncFactory<MocksType>) -> Self {
        container.register { self as! MocksType } // swiftlint:disable:this force_cast
        return self
    }
    
    @discardableResult func storeIn(_ container: SyncFactory<MocksType?>) -> Self {
        container.register { self as! MocksType? } // swiftlint:disable:this force_cast
        return self
    }
    
    @discardableResult func storeIn(_ container: SyncThrowingFactory<MocksType>) -> Self {
        container.register { self as! MocksType } // swiftlint:disable:this force_cast
        return self
    }
    
    @discardableResult func storeIn(_ container: SyncThrowingFactory<MocksType?>) -> Self {
        container.register { self as! MocksType? } // swiftlint:disable:this force_cast
        return self
    }
}

extension Mock where Self: Sendable, MocksType: Sendable {
    @discardableResult func storeIn(_ container: AsyncFactory<MocksType>) -> Self {
        container.register { self as! MocksType } // swiftlint:disable:this force_cast
        return self
    }
    
    @discardableResult func storeIn(_ container: AsyncFactory<MocksType?>) -> Self {
        container.register { self as! MocksType? } // swiftlint:disable:this force_cast
        return self
    }
    
    @discardableResult func storeIn(_ container: AsyncThrowingFactory<MocksType>) -> Self {
        container.register { self as! MocksType } // swiftlint:disable:this force_cast
        return self
    }
    
    @discardableResult func storeIn(_ container: AsyncThrowingFactory<MocksType?>) -> Self {
        container.register { self as! MocksType? } // swiftlint:disable:this force_cast
        return self
    }
}
