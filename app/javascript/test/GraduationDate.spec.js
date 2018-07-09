/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import GraduationDate from 'GraduationDate'
import axios from 'axios'
jest.mock('axios')

describe('GraduationDate.vue', () => {
  const resp = {data: [{'id': 'Fall 2017', 'label': 'Fall 2017', 'active': true}]}
  axios.get.mockResolvedValue(resp)

  it('renders a select element', () => {
    const wrapper = shallowMount(GraduationDate, {
    })
    expect(wrapper.findAll('select')).toHaveLength(1)
  })

  it('has a label that contains Graduation Date', () => {
    const wrapper = shallowMount(GraduationDate, {
    })
    expect(wrapper.findAll('label')).toHaveLength(1)
  })

  it('has the correct html', () => {
    const wrapper = shallowMount(GraduationDate, {
    })
    expect(wrapper.html()).toEqual(`<div><label>Graduation Date</label> <select name="etd[graduation_date]" class="form-control"></select></div>`)
  })
})
