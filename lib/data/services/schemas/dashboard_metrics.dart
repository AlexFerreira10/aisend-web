class DashboardMetrics {
  final int totalLeads;
  final int hotLeadsCount;
  final int warmLeadsCount;
  final double responseRate;

  const DashboardMetrics({
    required this.totalLeads,
    required this.hotLeadsCount,
    required this.warmLeadsCount,
    required this.responseRate,
  });
}
