/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import Degree from 'Degree'
import axios from 'axios'

jest.mock('axios')

describe('Degree.vue Display Legacy Degree', () => {
  const resp = {data: [{'id': 'Th.D.', 'label': 'Th.D.', 'active': true}]}
  axios.get.mockResolvedValue(resp)
  beforeEach(() => {
    const wrapper = shallowMount(Degree, {
    })
    wrapper.vm.$data.sharedState.allowTabSave = jest.fn((value) => { return false } )
    wrapper.vm.$data.sharedState.getSavedDegree = jest.fn((value) => { return 'phd' } )
    wrapper.vm.$data.degrees = resp.data

  })

  it('renders a select element', () => {
    const wrapper = shallowMount(Degree, {
    })
    wrapper.vm.getSelected(resp.data)
    expect(resp.data).toContainEqual({"active": true, "label": "phd", "selected": "selected", "value": "phd"})
  })
})
