/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ScanditCaptureCore

extension DataCaptureContext {
    
    private static let devKey =
//    "AelgG2AfQ9YqARqoTDpmkSsu6zcXPYRnD2mg2jgJ3litR7wkpmkPKuJuZP+bYUChUmiX1zA3akh1Z8HHvTXlSSswO8AGaMFbiBpArWVsL3M8XO1/jXkDDDlmi9cUe5hwdDR0iq8Y7xQHJrYKwAXwaO5m0OXt5yu9JCHzbZsIkiViXiz5oqg+BFud22fLEMCUXMjCMKinHZkWPMbtqYJRC5HeE3vPKwtEhdmKYpkHgA9VrXYQIk85zNSG/talEWhWKET8Hfx1zgsbxyA5chbOfBZRlV6Ttq6PTIJd3rurNB3KYRzE6aI1dyT4Y2A4RFy8lNFiQ0GlDn9ckbwyDeo6zmMpWXOKmuHrlQJHlAmjg01+2j6MiSZ/FaZhDJ7Mbr7wzcvBYf+gGnornD5y5BCIc/0GKKGVPGMLXSedIRTJVj7u3q7BscLpcMf9oEXRRcYVO8l3MC3QWLUcEq7Z+HEKFVHY3OnEX62qqLIOPAq0uq7ALFlEbw6PJaJtHLb0SQu+JlRivw7HuAIqSLCLsDsj4TtN5f89FOuWyAYROoyJnGKqMKV8jM5B32OcndpoG9P46Y069KyiP2AMhocRpT9nnIZ/54ETPHxf8oTXGfSWSKJAnAeXKE6nqI7ZEytSLuoppdwM7gYXseEGk96QGvUqR89m/bQEO2koYjrVsj1+klF/j3CFodP1flnMMtdvtu//xh3RL0aAKUxq6YatKRNGEO7oLS4a4FE8lVs4ThtoJh/n+TLoZMurA4Br9YvPyaipLtrlicWSfFQPTj+DBF9iEsAjk82aCUfUoVaYAzDFdBuwNiitl3kZTm9G/86Q4yPU"
//
        //"AeHee2AqQA6cOZyNXQMXo+Qm9N3ZQBrKolrt0yVaU6ChRaAIZFkNAW9hSfQGaGMV3kaU1qd8WJwVfJHFklp7xJR9xkQWTwHtjjxGOydAjdpodZn6e0h1pIJKsOeWV4poNSfV7hwSrPKYQVkfx3y/awg2DPmY3zT2EOgRMs+QTwShy+Z3gazVqviA25YOsD1kE6hh7K/P9b17gnyjSWn4AY2xfH88IVfGtVTt7vaY/eREbSW/FnhEATH6XV9WS8yJBUmh5mZkGuCVcagedzkDQsqDPIUVU+XmajJ7/jwmAIH4Cw2S36QBpOhWWZX3+QZC+HPJhHEMfjZhc+Ekf2yT69ai/EdxJRsvY/aqfCXGVrDhYLDUsFDCCXbTAg/mtPD+7c7I/o5pg0XNvBS/F3zSUaO8kSsfeACFFUugVPxaF3iTBW8OEhZL1U/SFe1j0L5Y3J0n4FsM1BClkQ2MXjQ6L4rXMETs19BkEDS4lQ+KoMyyNUq9I31ONbBi5BrvHgjLtxMVGU6Wc+8SN9k71DAHOUEQtfKFQq/PPK1WX+vGXp13K+31qA4Bqr7/ClQ4eqOzprRoa9GmY5IpTfKYrPFvek9mtx9YmlY/0KQDfFjRXVwTxUha9lfb2DqpeCND9x0UxhU35hpRWrzlSo7G3OnK3hpR16Ye557eZXPbvH+RLBPNvemCoWNLJDvWvp47Sqr9cHgXpCMppW2RGNS6odRUcYaG30PkKRRoJeNudQilw8VaCuSHTScSalNWSZp+tU7llL8MMPugPbxeGWCV0K6E2uuemD3LSz5m2CthlDeffwvf7WTkjk2r7i4crGo=" // Development Key
    
    "AbSSGxZ8NPhSIJKYgD4Nlucp58OiO9KdpwYFlDt+9yjvI2pLQndZa4YzJRw3U/kifm3USfpSFJj/Z2omYHlM6cZtS4yLTiyyJAgbXjNTtrSpTFPgxkCvktdWEtYCHngI8l8lIntpmhT0TkmgJXIMNb8R+0zkdNHhVGAM3NNCoO+NcS5IXUXu6ndjVfdyVdCUTU1Km3krhsdWOOfz00GfmWFnDHB4BswTOmcNuYB5wt/nWQsSq13/zgFF4U+9X6iHOmbkqkkrnFmnWCumaXQL3dBbZwxhXy5M+Vfm4zNulKq1QH8K+lLHSBBAfkx7aHtG733d7Q9lLXHKQ7YrwGWdTvNHVc2lZc7SBULdQUR8k8HAb4BFYV6fnnZi51D3ZOwB3WwHxlNyH/IZYrTnnmhq3L5KKe6KSrOgMEcmBiplmeadcAjWP0f1X7lLXRyKbcfGOHG+h8JC2c00EU3qzEhqvklFldQWddszPH6YUs5w9A7XaxrN0HSUJ0F0EYXqe/9z1z/3q+IYEmA7L9ogYxrTQEMy+8iekUN4MTms+kQqxJCbe18Ymwwo4sxVQPSkb3tRWxPLdnSFAER5qIzzp7O61v/h5xT6xPcsTrfFt310qHqqXYG/lCQRRWh46Ajkx8nbBU5gRAv9WwyUe/T5ZSzmS0NLAzirNbRyfHm0hp1wi1hAvQcC0J/Hl+o17QcOoAceTajmMD6DI3A7cSl52CfmxoWn6TAfAJURVPimQ7ux5zfN20pjbkkI8UK25Ifh+eUZ6OGDCErWel9viYLulSykMh6afOPcOLhJbbUClOIEcbxo7SRajZYFaMCR00sd4mjxU6PYK6RbpwQ+JqYl2MG/xezzrDTDXge9D0xsD320SfI4zrN4sc7Ly+wilojHVNi7C5nHrG01XYSv0dmQTp1zPsDa2WPL+RXRWG439XCPCVbAkakauZEfyROJU+qAf3WX1MWSU+oA97hlBRN5KHqgvXKg0UO2+9W+uyQ/YyuHtX3V6nsgBNH6PdRmdenyWhjxmx8QZ9EB0ouGHcQG8BbaESKnxIFrifxVujiKgMCdg7aT3pMzudhjgihp61Ex+Q6MPsCtIETyhRrrvG5J6YlgYcahVouT05EIRKfHBGT5Hbr8ey1+KWtH5Z570RWtnuHQH8VbHw3jZi61HP7wfe02HL9/gf74gpfhgupgls2Zip6OLCA/1eBntmZimmJzQ1WG"
    
    private static let licenseKey = (defaults.object(forKey: "scandit_licence_key") as? String) ?? devKey /*"AfSurNKBRiWpAolsyQqTJM8dn5ONHT4m306wwJp/PKy8Wc3/cVpoIcdHMQsyYPNE3FjEy7VqhPwAegXQU2t9kzoB22pPXSj8GjMCn4dErdRKIHvGWlT0nblNOyg8Q7Az7xFvIFsHC4ToCFlOToMu83m9xCA/o0TdAdhyD3R074lsoxpUEML/z/r8bJ2DhlvwwbwOT7Yd7NTlx9A76IWWDKjmQH8c3WRRAo+/33v6c+OM3XxD7Q6A9/O0eKpBlIw292FhXkmdRZoTkEdN/jOd015pS1pcutV7ycrEpI2i64WyCK09oqKnjCh3eqkV0nVeBxbtYq89gSzOTkZp7w+qjJaq6og02V43W1/dq2v14yJLTFyRpZ0dBxxBXqhIisiMBoCUeHPgdfYXkQHjJSkGOTJvTcVzByhLFtA8wogTRTrQYBeijPOMkrUH+LBYp4xheaE5IFkU8fJ35FQM2KD6NpRYXd4wM8wAnewCQTIA8066rlQanNr5AUV3rJjreqVM6fWgobXniNTba/7r8oRM/tubBs2oNBV6lbVqH9qXQ4mGU2kEbmzn66CyyeANispLtlwdnq3na/ptvlHWbAWnkWCKJnwhybGMlOVN1Oi2Ta0ay29V0iUfF4T/3Y9TCKXMZT5fEMLxe0mrT36g4PR5SouZlHlJZ5hBRc0utUVKlAISuR3WLq41mskNH8cvg4PowgNf5+OojFhnx4eJwYiRpWpqsJQQW8FiVrPrWVAw89lWhE70fFlEtUxEDeZqolMQNAc62Ycxy8ebUDpQFGta4G0/wGIA9oRKOYzsIe7rwBPhsd9ScSREVWnpfaQ=" */ // Production Key
    
    
    // Get a licensed DataCaptureContext
    static var licensed: DataCaptureContext {
        let devKeyValidDomains = ["tracktracerx.com", "aqbsolutions.com", "markacriativa.com.br","tracktracerx.com.br","gmail.com"]
        if let userEmail = defaults.value(forKey: "userName") as? String{
            if let domain = userEmail.components(separatedBy: "@").last, devKeyValidDomains.contains(domain){
                return DataCaptureContext(licenseKey: devKey)
            }else{
                return DataCaptureContext(licenseKey: licenseKey)
            }
        }else{
            return DataCaptureContext(licenseKey: devKey)
        }
    }
}
