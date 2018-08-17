/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import StartOverModal from '../../components/StartOverModal'
import { formStore } from '../../formStore'
describe('StartOverModal.vue', () => {
  it('shows up if showStartOver is true', () => {
    formStore.showStartOver = true
    const wrapper = shallowMount(StartOverModal, {
    })
    expect(wrapper.html()).toContain('Start Over With a New Submission')
  })

  it('does not show up if showStartOver is false', () => {
    formStore.showStartOver = false
    const wrapper = shallowMount(StartOverModal, {
    })
    expect(wrapper.html()).toEqual(undefined)
  })

  it('shows a spinner if submitted is true', () => {
    formStore.showStartOver = true
    formStore.submitted = true
    const wrapper = shallowMount(StartOverModal, {
    })
    expect(wrapper.html()).toContain('Removing your Submission ')
  })
})
