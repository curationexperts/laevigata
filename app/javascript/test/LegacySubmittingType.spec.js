/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import SubmittingType from 'SubmittingType'
import axios from 'axios'

jest.mock('axios')

describe('SubmittingType.vue Display Legacy SubmittingType', () => {
  const resp = {data: [{'id': 'Honors Thesis', 'label': 'Honors Thesis', 'active': true}]}
  axios.get.mockResolvedValue(resp)

  beforeEach(() => {
    const wrapper = shallowMount(SubmittingType, {
    })
    wrapper.vm.$data.sharedState.allowTabSave = jest.fn((value) => { return false } )
    wrapper.vm.$data.sharedState.getSubmittingType = jest.fn((value) => { return 'Major Paper' } )
    wrapper.vm.$data.submittingTypes = resp.data

  })

  it('renders a select element', () => {
    const wrapper = shallowMount(SubmittingType, {
    })
    wrapper.vm.getSelected(resp.data)
    expect(resp.data).toContainEqual({"active": true, "label": "Major Paper", "selected": "selected", "value": "Major Paper"})
  })
})
