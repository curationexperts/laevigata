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
const resp =  [{"id":"Divinity","label":"Divinity","active":true},{"id":"Ministry","label":"Ministry","active":true},{"id":"Pastoral Counseling","label":"Pastoral Counseling","active":true},{"id":"Theological Studies","label":"Theological Studies","active":true}]
axios.get.mockResolvedValue(resp)
formStore.getSavedOrSelectedDepartment = () => { return 'Divinity' }
describe('Department.vue', () => {
  it('it restores the correct value', () => {
    const wrapper = mount(Department, {
    })
    wrapper.vm.$data.school = "Candler School of Theology"
    wrapper.vm.$data.selected = formStore.getSavedOrSelectedDepartment()
    expect(wrapper.html()).toContain('Divinity')
  })
  it('has a disabled default ', () => {
    const wrapper = mount(Department, {
    })
    formStore.departments = [{ "value": 1, "active": true, "label": "Select a Department", "disabled":"disabled" ,"selected": "selected"}]
    wrapper.vm.$data.school = "Candler School of Theology"
    formStore.getSavedOrSelectedDepartment = () => { return false }
    wrapper.vm.$data.selected = 'Select a Department'
    expect(wrapper.html()).toContain('disabled')
  })
})
