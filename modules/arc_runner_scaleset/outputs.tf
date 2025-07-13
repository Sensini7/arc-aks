output "release_name" {
  value = helm_release.arc_runner_scale_set.name
}

output "release_status" {
  value = helm_release.arc_runner_scale_set.status
}