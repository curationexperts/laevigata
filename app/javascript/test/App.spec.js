/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import App from 'App'

describe('App.vue', () => {
  it('renders a form', () => {
    const wrapper = shallowMount(App, {
    })
    expect(wrapper.findAll('form')).toHaveLength(1)
  })

  describe('Tab Navigation', () => {
    it('enables the completed and current tabs', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.$data.form.tabs.about_me.complete = true
      wrapper.vm.$data.form.tabs.my_program.complete = true
      wrapper.vm.$data.form.tabs.my_advisor.currentStep = true

      wrapper.vm.enableTabs()

      expect(wrapper.vm.$data.form.tabs.about_me.disabled).toBe(false)
      expect(wrapper.vm.$data.form.tabs.my_program.disabled).toBe(false)
      expect(wrapper.vm.$data.form.tabs.my_advisor.disabled).toBe(false)
    })

    it('can set the complete property of a tab', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.setComplete('About Me')

      expect(wrapper.vm.$data.form.tabs.about_me.complete).toBe(true)
    })

    it('sets the current tab property', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.setCurrentStep('My Advisor')

      expect(wrapper.vm.$data.form.tabs.my_advisor.currentStep).toBe(true)
    })

    it('determines the next current tab', () => {
      const wrapper = shallowMount(App, {
      })
      wrapper.vm.nextStepIsCurrent(3)

      expect(wrapper.vm.$data.form.tabs.keywords.currentStep).toBe(true)
    })
  })
})
