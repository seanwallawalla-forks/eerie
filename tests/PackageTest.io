PackageTest := UnitTest clone do (

    testInstall := method(
        package := Package with("tests/_packs/AFakePack")
        self _cleanUp(package)
        package install

        assertEquals(
            package children keys sort,
            package struct manifest packs keys sort)

        installed := package struct packs directories map(directories at(0)) \
            map(dir, Package with(dir path))

        assertEquals(
            list("BFakePack", "CFakePack", "DFakePack"), 
            installed map(struct manifest name) sort)

        installed foreach(pack,
            assertEquals(SemVer fromSeq("0.1.0"), pack struct manifest version))

        staticLib := File with(
            package children at("CFakePack") struct staticLibPath)
        assertTrue(staticLib exists)

        dynLib := File with(
            package children at("CFakePack") struct dllPath)
        assertTrue(dynLib exists)

        assertEquals(list("testbin"), package struct binDest files map(name))

        self _cleanUp(package))

    _cleanUp := method(package, 
        package struct packs remove
        package struct binDest remove
        package struct build root remove)

    testVersions := method(
        package := Package with("tests/_tmp/CFakePackUpdate")
        assertEquals(23, package versions size))

    testChildren := method(
        package := Package with("tests/installed/AFakePack")
        expected := list("AFakePack", "BFakePack")
        assertEquals(expected,
            package children at("CFakePack") children keys sort)

        expected = list("AFakePack", "CFakePack")
        assertEquals(expected, 
            package children at("BFakePack") children keys sort)

        self _checkParents(package)

        assertFalse(package recursive)

        # BFakePack recursivity

        assertFalse(package children at("BFakePack") recursive)
        assertTrue(
            package children at("BFakePack") children at("AFakePack") recursive)

        package children \
            at("BFakePack") children \
                at("CFakePack") children foreach(name, child,
            assertTrue(child recursive))

        # CFakePack recursivity

        assertFalse(package children at("CFakePack") recursive)
        assertTrue(
            package children at("CFakePack") children at("AFakePack") recursive)

        package children \
            at("CFakePack") children \
                at("BFakePack") children foreach(name, child,
            assertTrue(child recursive)))

    _checkParents := method(package,
        package children ?foreach(name, child,
            if (child recursive not, self _checkParents(child))
            assertEquals(child parent, package)))

    testMissing := method(
        package := Package with("tests/_packs/AFakePack")
        assertEquals(package missing, package struct manifest packs values))

    testChanged := method(
        package := Package with("tests/installed/AFakePack")
        assertEquals("DFakePack", package changed at(0) name))

)
