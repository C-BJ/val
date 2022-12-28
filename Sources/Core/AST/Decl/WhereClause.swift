import Utils

/// A where clause.
public struct WhereClause: Codable {

  /// The expression of a type constraint defined in a generic clause.
  public enum ConstraintExpr: Codable {

    /// An equality constraint involving one or two skolems.
    case equality(
      l: NodeID<NameExpr>,
      r: AnyTypeExprID)

    /// A conformance constraint on a skolem.
    case conformance(
      l: NodeID<NameExpr>,
      traits: TraitComposition)

    /// A constraint on a value parameter.
    case value(AnyExprID)

  }

  /// The constraint expressions in the clause.
  public let constraints: [SourceRepresentable<ConstraintExpr>]

  public init(constraints: [SourceRepresentable<WhereClause.ConstraintExpr>]) {
    self.constraints = constraints
  }

}