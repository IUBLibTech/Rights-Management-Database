module AccessDeterminationHelper
  DEFAULT_ACCESS = "Default IU Access - Not Reviewed"
  IU_ACCESS = "IU Access - Reviewed"
  WORLD_WIDE_ACCESS = "World Wide Access"
  RESTRICTED_ACCESS = "Restricted Access"
  ACCESS_DECISIONS = [DEFAULT_ACCESS, IU_ACCESS, WORLD_WIDE_ACCESS, RESTRICTED_ACCESS]
  ORDERED_ACCESS_DECISIONS = [RESTRICTED_ACCESS, IU_ACCESS, DEFAULT_ACCESS, WORLD_WIDE_ACCESS]
  # default access is the highest rank so that it is omitted from subsequent access requests - any access determination
  # after the default value is considered 'reviewed'
  ACCESS_RANKING = {
      RESTRICTED_ACCESS => 1,
      IU_ACCESS => 2,
      WORLD_WIDE_ACCESS => 3,
      DEFAULT_ACCESS => 2
  }

  # compares access to bounding_access and returns true if and only if access is less restrictive or the same access
  # level as defined by the rankings in ACCESS_RANKING
  def is_more_restrictive_than?(access, bounding_access)
    return true if bounding_access.nil? && ACCESS_DECISIONS.include?(access)
    raise "Invalid Access Determination: #{access}" unless ACCESS_DECISIONS.include?(access)
    raise "Invalid Access Determination: #{bounding_access}" unless ACCESS_DECISIONS.include?(bounding_access)
    ACCESS_RANKING[access] <= ACCESS_RANKING[bounding_access]
  end
end
