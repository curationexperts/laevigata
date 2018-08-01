/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Embargo from '../../../components/submit/Embargo'
import axios from 'axios'
jest.mock('')

describe('Embargo.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(Embargo, {
    })
    expect(wrapper.html()).toContain('Embargo')
  })
})
