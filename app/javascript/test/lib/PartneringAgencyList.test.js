/* global test */
/* global expect */
/* global jest */

import PartneringAgency from '../../lib/PartneringAgency'
import PartneringAgencyList from '../../lib/PartneringAgencyList'
import { formStore } from '../../formStore'
import axios from 'axios'
jest.mock('axios')

jest.mock('../../formStore', () => {
  return function () {
    return {
      formStore: () => {
      }
    }
  }
})

test('that you can add a committee partneringAgency to the list', () => {
  var partneringAgency = new PartneringAgency({ value: 'test' })
  var partneringAgencyList = new PartneringAgencyList()
  partneringAgencyList.add(partneringAgency)

  expect(partneringAgencyList.partneringAgencies()[0].value).toEqual('test')
})

test('that you can remove a PartneringAgency', () => {
  var partneringAgency = new PartneringAgency({ value: 'test' })
  var partneringAgencyList = new PartneringAgencyList()
  partneringAgencyList.add(partneringAgency)

  partneringAgencyList.remove(partneringAgency)
  expect(partneringAgencyList.partneringAgencies().length).toEqual(0)
})

test('that you can load data from attributes in savedData', () => {
  var attributes = { 'partnering_agencies': ['test'] }
  var partneringAgencyList = new PartneringAgencyList()
  partneringAgencyList.load(attributes)
  expect(partneringAgencyList.partneringAgencies()[0].value).toEqual(['test'])
})

test('that you can add an empty partneringAgency', () => {
  var partneringAgencyList = new PartneringAgencyList()
  partneringAgencyList.addEmpty()
  expect(partneringAgencyList.partneringAgencies().length).toEqual(1)
})