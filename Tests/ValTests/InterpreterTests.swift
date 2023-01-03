import Core
import Utils
import XCTest
import FrontEnd
import IR

final class InterpreterTests: XCTestCase {
  func testSimple() throws {
    let input = SourceFile(
      contents: """
        public fun main() {
        }
        """)

    var syntax = AST()
    let moduleNode = try syntax.insert(wellFormed: ModuleDecl(name: "Main"))

    let parseResult = Parser.parse(input, into: moduleNode, in: &syntax)
    XCTAssertFalse(parseResult.failed, "\(parseResult.diagnostics)")
    if parseResult.failed { return }

    var checker = TypeChecker(program: ScopedProgram(ast: syntax))
    let wellTyped = checker.check(module: moduleNode)
    XCTAssert(wellTyped, "\(checker.diagnostics)")
    if !wellTyped { return }

    let typedProgram = TypedProgram(
      annotating: checker.program,
      declTypes: checker.declTypes,
      exprTypes: checker.exprTypes,
      implicitCaptures: checker.implicitCaptures,
      referredDecls: checker.referredDecls,
      foldedSequenceExprs: checker.foldedSequenceExprs)

    var irModule = Module(moduleNode, in: typedProgram)

    // Run mandatory IR analysis and transformation passes.
    var pipeline: [TransformPass] = [
      ImplicitReturnInsertionPass(),
      DefiniteInitializationPass(program: typedProgram),
      LifetimePass(program: typedProgram),
    ]

    var success = true
    for i in 0..<pipeline.count {
      for f in 0..<irModule.functions.count {
        success = pipeline[i].run(function: f, module: &irModule)
        XCTAssert(success, "\(type(of: pipeline[i]))\n\(pipeline[i].diagnostics)")
      }
    }
    // print(irModule)
  }
}
