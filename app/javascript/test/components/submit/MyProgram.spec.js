/* global describe */
/* global it */
/* global expect */
import Vue from 'vue'
import { shallowMount } from '@vue/test-utils'
import MyProgram from '../../../components/submit/MyProgram'
import { formStore } from '../../../formStore'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn((value) =>{ return 'Rollins School of Public Health' })
formStore.savedData['partnering_agency'] = ['CDC']

describe('MyProgram.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(MyProgram, {
    })
    expect(wrapper.html()).toContain('My Program')
  })
})
