class SyncProgress {
  int preparedCategories = 0;
  int preparedProducts = 0;
  int preparedSales = 0;
  int skippedSales = 0;
  int appliedOps = 0;
  int duplicateOps = 0;
  int failedOps = 0;
  int pulledCategories = 0;
  int insertedCategories = 0;
  int updatedCategories = 0;
  int pulledProducts = 0;
  int insertedProducts = 0;
  int updatedProducts = 0;
  bool terminalMissing = false;
  bool backendShiftMissing = false;
  final List<String> failureReasons = [];

  void addFailure(String reason) => failureReasons.add(reason);

  void merge(SyncProgress other) {
    preparedCategories += other.preparedCategories;
    preparedProducts += other.preparedProducts;
    preparedSales += other.preparedSales;
    skippedSales += other.skippedSales;
    appliedOps += other.appliedOps;
    duplicateOps += other.duplicateOps;
    failedOps += other.failedOps;
    pulledCategories += other.pulledCategories;
    insertedCategories += other.insertedCategories;
    updatedCategories += other.updatedCategories;
    pulledProducts += other.pulledProducts;
    insertedProducts += other.insertedProducts;
    updatedProducts += other.updatedProducts;
    terminalMissing = terminalMissing || other.terminalMissing;
    backendShiftMissing = backendShiftMissing || other.backendShiftMissing;
    failureReasons.addAll(other.failureReasons);
  }
}
