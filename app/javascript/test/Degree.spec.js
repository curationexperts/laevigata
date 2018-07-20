/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import Degree from 'Degree'
import axios from 'axios'

jest.mock('axios')

describe('Degree.vue', () => {
  const resp = {data: [{'id': 'Th.D.', 'label': 'Th.D.', 'active': true}]}
  axios.get.mockResolvedValue(resp)

  it('renders a select element', () => {
    const wrapper = shallowMount(Degree, {
    })
    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Degree', () => {
    const wrapper = shallowMount(Degree, {
    })
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(Degree, {
    })
    expect(wrapper.html()).toEqual(`<div><label for="degree">Degree</label> <select id="degree" name="etd[degree]" aria-required="true" class="form-control"></select></div>`)
  })
})
