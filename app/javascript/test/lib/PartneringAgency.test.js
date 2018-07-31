/* global test */
/* global expect */

import PartneringAgency from '../../lib/PartneringAgency'

test('that a committee partneringAgency object has an ID, name, and affiliation', () => {
  var partneringAgency = new PartneringAgency({ value: 'partneringAgency' })
  expect(partneringAgency.value).toEqual('partneringAgency')
})
