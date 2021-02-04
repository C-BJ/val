import AST

/// The type checker for Val's statements.
struct StmtChecker: StmtVisitor {

  typealias StmtResult = Void

  /// The top-level type checker.
  unowned let checker: TypeChecker

  /// The declaration space in which the visited statement resides.
  let useSite: DeclSpace

  func visit(_ node: BraceStmt) {
    for i in 0 ..< node.stmts.count {
      switch node.stmts[i] {
      case let decl as Decl:
        checker.check(decl: decl)

      case let stmt as Stmt:
        checker.check(stmt: stmt, useSite: node)

      case var expr as Expr:
        checker.check(expr: &expr, useSite: node)
        node.stmts[i] = expr

      default:
        fatalError("unexpected node")
      }
    }
  }

  func visit(_ node: RetStmt) {
    guard let funDecl = node.funDecl else { return }
    let context = funDecl.type.context

    // Retrieve the expected return type.
    let retType: ValType
    if let sign = funDecl.retSign {
      let signType = sign.realize(unqualifiedFrom: funDecl)

      if signType.props.contains(.hasTypeParams) {
        funDecl.prepareGenericEnv()
        retType = funDecl.genericEnv.contextualize(signType, from: useSite)
      } else {
        retType = signType
      }

      guard retType.isWellFormed else { return }
    } else {
      retType = context.unitType
    }

    if var value = node.value {
      // Type check the returned expression.
      checker.check(expr: &value, contextualType: retType, useSite: useSite)
      node.value = value
    } else if (retType != context.unitType) && !(funDecl is CtorDecl) {
      // Complain that non-unit function should return a value.
      context.report(.missingReturnValue(range: node.range))
    }
  }

}