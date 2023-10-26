/// Describes the compiler; used as source of truth for conditional compilation.
public struct CompilerInfo {

  /// The operating-system used when performing the compilation.
  let os: String
  /// The architecture of the machine doing the compilation.
  let arch: String
  /// The name of the compiler.
  let compiler: String
  /// The version of the compiler.
  let compilerVersion: SemanticVersion
  /// The version of the Hylo language version we are targeting.
  let hyloVersion: SemanticVersion

  /// We only need one instance of this struct, to represent the compiler information.
  public static let instance = CompilerInfo()

  /// Creates an instance with the properties of the machine running this initializer.
  private init() {
    os = CompilerInfo.currentOS()
    arch = CompilerInfo.currentArch()
    compiler = "hc"
    compilerVersion = SemanticVersion(major: 0, minor: 1, patch: 0)
    hyloVersion = SemanticVersion(major: 0, minor: 1, patch: 0)
  }

  /// The name of the operating system on which this function is run.
  private static func currentOS() -> String {
    #if os(macOS)
      return "MacOS"
    #elseif os(Linux)
      return "Linux"
    #elseif os(Windows)
      return "Windows"
    #else
      return "Unknown"
    #endif
  }

  /// The architecture on which this function is run.
  private static func currentArch() -> String {
    #if arch(i386)
      return "i386"
    #elseif arch(x86_64)
      return "x86_64"
    #elseif arch(arm)
      return "arm"
    #elseif arch(arm64)
      return "arm64"
    #else
      return "Unknown"
    #endif
  }

}
