/* global describe */
/* global it */
/* global expect */
/* global jest */
import { shallowMount, flushPromises } from '@vue/test-utils'
import Department from 'Department'
import axios from 'axios'
import * as formHelpers from "../lib/formHelpers";
jest.mock('axios')

describe('Department.vue', () => {
  beforeEach(() => {
    // mock an response from the candler_rograms endpoint
    const mockResponse =  {data:
        [ {"id":"Divinity",             "label":"Divinity",             "active":true},
          {"id":"Ministry",             "label":"Ministry",             "active":true},
          {"id":"Pastoral Counseling",  "label":"Pastoral Counseling",  "active":false},
          {"id":"Theological Studies",  "label":"Theological Studies",  "active":false}]}
    axios.get.mockResolvedValue(mockResponse)
  })

  afterEach(() => {
    // restore any spies created with spyOn
    jest.restoreAllMocks()
  })

  it('lists active departments', async () =>  {
    const wrapper = shallowMount(Department, {
      data() {
        // set Candler as the previously saved school
        return {sharedState: {savedData: {school: 'Candler School of Theology'}}}
      }
    })

    await flushPromises

    const enabled_options = wrapper.findAll('option:not([disabled])').wrappers.map((wrapper) => wrapper.text())
    expect(enabled_options).toEqual(['Divinity', 'Ministry'])
  })

  it('has a disabled default value', async () =>  {
    const wrapper = shallowMount(Department, {
      data() {
        // set Candler as the previously saved school
        return {sharedState: {savedData: {school: 'Candler School of Theology'}}}
      }
    })

    await flushPromises

    // use findAll instead of find to ensure we only have one disabled option
    const disabled_option = wrapper.findAll('#department option[disabled]').wrappers.map((wrapper) => wrapper.text())
    expect(disabled_option).toEqual(['Select a Department'])
  })

  it('lists inacive departments in advanced mode', async () =>  {
    // render the form using the admin view option
    jest.spyOn(formHelpers, "showInactive").mockReturnValue(true);

    const wrapper = shallowMount(Department, {
      data() {
        // set Candler as the previously saved school
        return {sharedState: {savedData: {school: 'Candler School of Theology'}}}
      }
    })

    await flushPromises

    const enabled_options = wrapper.findAll('option:not([disabled])').wrappers.map((wrapper) => wrapper.text())
    expect(enabled_options).toEqual(['Divinity', 'Ministry', '⚠️ Pastoral Counseling', '⚠️ Theological Studies'])
  })

  it('lists includes inactive departments if they were preiously saved', async () =>  {
    const wrapper = shallowMount(Department, {
      data() {
        // set Candler as the previously saved school
        return {sharedState: {savedData: {school: 'Candler School of Theology', department: 'Theological Studies'}}}
      }
    })

    await flushPromises

    const enabled_options = wrapper.findAll('option:not([disabled])').wrappers.map((wrapper) => wrapper.text())
    expect(enabled_options).toEqual(['Divinity', 'Ministry', 'Theological Studies'])
  })

  it('Uses "Specialty" instead of "Department" for School of Nursing ', async () =>  {
    const wrapper = shallowMount(Department, {
      data() {
        // set Nursing as the previously saved school
        return {sharedState: {savedData: {school: 'Nell Hodgson Woodruff School of Nursing'}}}
      }
    })

    await flushPromises

    // Check the text of the first option
    expect(wrapper.find('#department option').text()).toEqual('Select a Specialty')
  })})
