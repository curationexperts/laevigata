/* global describe */
/* global it */
/* global expect */
/* global jest */
import { mount } from '@vue/test-utils'
import School from 'School'
import axios from 'axios'
import { formStore } from 'formStore'

jest.mock('axios')
window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn()
window.localStorage.setItem = jest.fn()

describe('School.vue', () => {
  const resp = {data: [{'id': 'Candler School of Theology'}]}
  axios.get.mockResolvedValue(resp)

  it('is a a select box before saving', () => {
    const wrapper = mount(School, {
    })
    expect(wrapper.html()).toContain(`<div><label for="school">School</label> <select id="school" aria-required="true" class="form-control"><option disabled="disabled" value="">`)
  })

  it('is non-editable text after saving', () => {
    formStore.savedData.school = 'candler'
    formStore.getSchoolText = jest.fn(() => { 'candler' })

    const wrapper = mount(School, {
    })
    wrapper.vm.$data.sharedState.schools.options = [{"text":"Select a School","value":"","disabled":"disabled","selected":"selected"},{"text":"Candler School of Theology","value":"candler"},{"text":"Emory College","value":"emory"},{"text":"Laney Graduate School","value":"laney"},{"text":"Rollins School of Public Health","value":"rollins"}]
    expect(wrapper.html()).not.toContain('<select')
    expect(wrapper.html()).toContain(`no-edit-school`)
  })

  it('does not let you change in the edit screen', () => {
    formStore.savedData.school = 'candler'
    formStore.getSchoolText = jest.fn(() => { 'candler' })

    formStore.allowTabSave = jest.fn(() => {return false})
   
    const wrapper = mount(School, {
    })
      wrapper.vm.$data.sharedState.schools.options = [{"text":"Select a School","value":"","disabled":"disabled","selected":"selected"},{"text":"Candler School of Theology","value":"candler"},{"text":"Emory College","value":"emory"},{"text":"Laney Graduate School","value":"laney"},{"text":"Rollins School of Public Health","value":"rollins"}]

   expect(wrapper.html()).not.toContain('<button')
   expect(wrapper.html()).toContain(`no-edit-school`)
  })
})
