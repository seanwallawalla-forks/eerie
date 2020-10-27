VcsDownloader := Eerie Downloader clone do(
    vcs := Object clone do(
        doRelativeFile("vcs/git.io")
        doRelativeFile("vcs/svn.io")
        doRelativeFile("vcs/hg.io")
    )

    chosenVcs ::= nil

    whichVcs := method(_uri,
        self vcs slotNames foreach(name,
            self vcs getSlot(name) check(_uri) ifTrue(
                return name
                break))
        nil)

    chooseVcs := lazySlot(
        self setChosenVcs(self vcs getSlot(self whichVcs(self url))))

    // Reimplementation of default Downloader methods
    canDownload = method(_uri, self whichVcs(_uri) != nil)

    download = method(
        self chooseVcs
        self destDir files isEmpty ifTrue(self destDir remove)
        self runCommands(self chosenVcs download))

    runCommands := method(cmds,
        cmds foreach(cmd, self vcsCmd(cmd interpolate))

        true)

    vcsCmd := method(args,
        dir := nil
        Directory with(self destDir path) exists ifTrue(dir = self destDir path)

        # FIXME this should be replaced with exception catch
        statusCode := Eerie sh(self chosenVcs cmd .. " " .. args, false, dir)
        if(statusCode == 0, return true, return false))

)
