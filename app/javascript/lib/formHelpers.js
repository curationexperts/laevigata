export function showInactive () {
    return document.getElementById('saved_data')?.dataset?.formLevel === 'advanced'
}

export function labelFor(label, active) {
    if (active === true) {
        return label
    } else {
        return `⚠️ ${label}`
    }
}
