@attached(member, names: arbitrary)
public macro Updatable() =
  #externalMacro(
    module: "UpdatableMacro",
    type: "UpdatableMacro"
  )

@attached(peer)
public macro UpdatableIgnored() =
  #externalMacro(
    module: "UpdatableMacro",
    type: "UpdatableIgnoredMacro"
  )
