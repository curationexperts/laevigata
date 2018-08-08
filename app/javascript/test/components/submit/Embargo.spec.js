/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Embargo from '../../../components/submit/Embargo'
import { formStore } from '../../../formStore'
import axios from 'axios'

formStore.getSavedOrSelectedSchool = jest.fn(() => {return 'emory'})

describe('Embargo.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(Embargo, {
    })
    expect(wrapper.html()).toContain('Embargo')
  })
})
