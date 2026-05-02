/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount, flushPromises } from '@vue/test-utils'
import GraduationDate from 'GraduationDate'
import axios from 'axios'
import * as formHelpers from '../lib/formHelpers'

jest.mock('axios')

describe('GraduationDate.vue with an inactive legacy term', () => {
  beforeEach(() => {
    // mock an abridged response from the graduation_dates endpoint
    const mockResponse = {
      data: [{'id': 'Fall 2017', 'label': 'Fall 2017', 'active': true}, {'id': '2013', 'label': '2013', 'active': false}]
    }
    axios.get.mockResolvedValue(mockResponse)
  })

  afterEach(() => {
    // restore any spies created with spyOn
    jest.restoreAllMocks();
  });

  it('selects the legacy option when set in the source ETD', async () => {
    const wrapper = shallowMount(GraduationDate)
    // set saved academic term
    wrapper.vm.$data.sharedState.savedData['graduation_date'] = "2013"
    await flushPromises

    expect(wrapper.find('#graduation-date').element.value).toEqual('2013')
  })

  it('displays expected options', async () => {
    const wrapper = shallowMount(GraduationDate)
    // set saved academic term
    wrapper.vm.$data.sharedState.savedData['graduation_date'] = "2013"
    await flushPromises

    const option_labels = wrapper.findAll('#graduation-date option').wrappers.map((option) => option.text())
    expect(option_labels).toEqual(['Select a Graduation Date', 'Fall 2017', '2013'])
  })

  it('does not display inactive options when they are not selected', async () => {
    const wrapper = shallowMount(GraduationDate)
    // clear saved academic term
    wrapper.vm.$data.sharedState.savedData['graduation_date'] = ""
    await flushPromises

    const option_labels = wrapper.findAll('#graduation-date option').wrappers.map((option) => option.text())
    expect(option_labels).toEqual(['Select a Graduation Date', 'Fall 2017'])
  })

  it('displays inactive options in admin view even when they are not selected', async () => {

    // render the form using the admin view option
    jest.spyOn(formHelpers, "showInactive").mockReturnValue(true);

    const wrapper = shallowMount(GraduationDate)

    // clear saved academic term
    wrapper.vm.$data.sharedState.savedData['graduation_date'] = ""
    await flushPromises

    const option_labels = wrapper.findAll('#graduation-date option').wrappers.map((option) => option.text())
    expect(option_labels).toEqual(['Select a Graduation Date', 'Fall 2017', '⚠️ 2013 (inactive)'])
  })
})
