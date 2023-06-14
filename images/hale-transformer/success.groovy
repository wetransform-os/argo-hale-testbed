// the transformation must have been completed
assert aggregated['eu.esdihumboldt.hale.transform'].report.completed == true
// without errors
assert aggregated['eu.esdihumboldt.hale.transform'].report.errors == 0

// there must have been objects created as part of the transformation
assert aggregated['eu.esdihumboldt.hale.transform'].createdPerType.any { name, count -> count > 0 }
