import {
  CurrencyConversionDictSchema,
  CurrencyConversionSchema,
  I18nInfoSchema,
  LanguageListSchema,
} from '@algomart/schemas'
import { FastifyInstance } from 'fastify'

import {
  getCurrencyConversion,
  getCurrencyConversions,
  getI18nInfo,
  getLanguages,
} from './i18n.routes'

import { appErrorHandler } from '@/utils/errors'

export async function i18nRoutes(app: FastifyInstance) {
  const tags = ['i18n']

  // Errors
  app.setErrorHandler(appErrorHandler(app))

  // Services/Routes
  app
    .get(
      '/currencyConversion',
      {
        schema: {
          tags,
          description:
            'Get currency conversion from source currency to target currency',
          response: {
            200: CurrencyConversionSchema,
          },
        },
      },
      getCurrencyConversion
    )
    .get(
      '/currencyConversions',
      {
        schema: {
          tags,
          description:
            'Get currency conversions for given source currency, defaulting to environment currency',
          response: {
            200: CurrencyConversionDictSchema,
          },
        },
      },
      getCurrencyConversions
    )
    .get(
      '/languages',
      {
        schema: {
          tags,
          description: 'Get list of languages',
          response: {
            200: LanguageListSchema,
          },
        },
      },
      getLanguages
    )
    .get(
      '/i18n-info',
      {
        schema: {
          tags,
          description:
            'Get combined response of currencyConversions for CMS currency and languages',
          response: {
            200: I18nInfoSchema,
          },
        },
      },
      getI18nInfo
    )
}