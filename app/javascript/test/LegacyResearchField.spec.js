/* global describe */
/* global it */
/* global expect */
/* global jest */

import Vue from 'vue'
import { shallowMount } from '@vue/test-utils'
import ResearchField from 'ResearchField'
import axios from 'axios'

jest.mock('axios')

describe('ResearchField.vue Display Legacy ResearchField', () => {
  const resp = {data: [{'id': 'Horticulture', 'active': true, 'label': '0237'}]}
  axios.get.mockResolvedValue(resp)

  let Constructor;
  let vm;

  beforeEach(() => {
    Constructor = Vue.extend(ResearchField);
    vm = new Constructor().$mount();
    vm.$data.sharedState.savedData['research_field'] = ['Anthropology']
    vm.$data.sharedState.allowTabSave = jest.fn((value) => { return false } )
  })

  afterEach(() => {
    vm.$destroy()
  })

  it('renders a select element', () => {
    expect(vm.$data.researchFields).toContainEqual({"active": true, "id": "Anthropology", "label": "Anthropology"}, {"active": true, "id": "Horticulture", "label": "0237"})
  })
})
