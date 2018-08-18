/**
 * Safari 11 has a bug where form submission requests are not made if
 * there are file elements with no values. This function removes any
 * blank elements from the FormData.
 *
 *  See https://bugs.webkit.org/show_bug.cgi?id=184490
 */
export function formDataNoBlankFiles(formElementId) {
  const formElements = document.getElementById(formElementId)
  const fd = new FormData()
  for (let e of formElements.elements) {
    if (e.name === 'primary_files[]' && e.value === '') {
    } else if (e.name === 'supplemental_files[]' && e.value === '') {
    } else {
      fd.set(e.name, e.value)
    }
  }
  return fd
}
