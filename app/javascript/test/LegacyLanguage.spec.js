/* global describe */
/* global it */
/* global expect */
/* global jest */

import { shallowMount } from '@vue/test-utils'
import Language from 'Language'
import axios from 'axios'

jest.mock('axios')

describe('Language.vue Display Legacy Language', () => {
  const resp = {data: [{'id': 'French', 'label': 'French', 'active': true}]}
  axios.get.mockResolvedValue(resp)
  beforeEach(() => {
    const wrapper = shallowMount(Language, {
    })
    wrapper.vm.$data.sharedState.allowTabSave = jest.fn((value) => { return false } )
    wrapper.vm.$data.sharedState.getSavedLanguage = jest.fn((value) => { return 'Greek' } )
    wrapper.vm.$data.languages = resp.data

  })

  it('renders a select element', () => {
    const wrapper = shallowMount(Language, {
    })
    wrapper.vm.getSelected(resp.data)
    expect(resp.data).toContainEqual({"active": true, "label": "Greek", "selected": "selected", "value": "Greek"})
  })
})
