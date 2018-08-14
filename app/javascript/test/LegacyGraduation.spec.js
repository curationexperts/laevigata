/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import GraduationDate from 'GraduationDate'
import axios from 'axios'

jest.mock('axios')
describe('GraduationDate.vue with an inactive legacy term', () => {
  const respData = {data: [
        {'id': 'Fall 2017', 'label': 'Fall 2017', 'active': true}, {'id': '2013', 'label': '2013', 'active': true}]}

  axios.get.mockResolvedValue(respData)

  beforeEach(() => {
    const wrapper = shallowMount(GraduationDate, {
    })
    wrapper.vm.$data.graduationDates = respData
    wrapper.vm.$data.sharedState.getGraduationDate = jest.fn(() => {
      return '2013'
    })
  })

  it('will set the legacy option properties active = true and selected = selected', () => {
    const wrapper = shallowMount(GraduationDate, {
    })
    wrapper.vm.$data.graduationDates = respData

    const expected_option_data = {data: [{'id': 'Fall 2017', 'label': 'Fall 2017', 'active': true}, {'id': '2013', 'label': '2013', 'active': true, 'selected': 'selected'}]}

    expect(wrapper.vm.getSelected(respData)).toEqual(expected_option_data)
  })
})
