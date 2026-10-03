locals {
  chart_files = {
    for f in fileset(var.chart_dir, "**") : f => file("${var.chart_dir}/${f}")
    if !anytrue([for p in var.exclude_patterns : can(regex(p, f))])
  }
}
