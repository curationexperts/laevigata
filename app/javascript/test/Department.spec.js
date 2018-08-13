/* global describe */
/* global it */
/* global expect */
/* global jest */
import { mount } from '@vue/test-utils'
import Department from 'Department'
import axios from 'axios'
import { formStore } from 'formStore'
jest.mock('axios')

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn()
window.localStorage.setItem = jest.fn()

formStore.departments = [{"id":"Divinity","label":"Divinity","active":true},{"id":"Ministry","label":"Ministry","active":true},{"id":"Pastoral Counseling","label":"Pastoral Counseling","active":true},{"id":"Theological Studies","label":"Theological Studies","active":true}]
formStore.getSavedOrSelectedDepartment = () => { return 'Divinity' }
describe('Department.vue', () => {
  it('it restores the correct value', () => {
    const wrapper = mount(Department, {
    })
    wrapper.vm.$data.selected = formStore.getSavedOrSelectedDepartment()
    
    expect(wrapper.html()).toContain('Divinity')
  })
})