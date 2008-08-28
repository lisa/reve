#--
# Code copyright Lisa Seelye, 2007-2008. www.crudvision.com
# Reve is not licensed for commercial use. For other uses there are no
# restrictions.
#
# The author is not adverse to tokens of appreciation in the form of Eve ISK,
# ships, and feedback. Please use
# http://www.crudvision.com/reve-ruby-eve-online-api-library/ to provide
# feedback or send ISK to Raquel Smith in Eve. :-)
#++
module Reve
  # Exceptions live here.
  module Exceptions
    # Raise the flag!
    def self.raise_it(code,msg = "No Error Message From CCP Server (But one DID occur!)")
      msg = "(#{code.to_s}) #{msg}"
      case code
      when 100
        raise WalletNotPreviouslyLoaded.new(msg)
      when 101, 103
        raise WalletExhausted.new(msg)
      when 102
        raise WalletPreviouslyLoaded.new(msg)
      when 104
        raise KeyNotFound.new(msg)
      when 105
        raise InvalidCharacterID.new(msg)
      when 106
        raise MustProvideUserIDParameterForAuthentication.new(msg)
      when 107
        raise InvalidBeforeRefID.new(msg)
      when 108
        raise InvalidAccountKey.new(msg)
      when 109
        raise AccountKeyOutOfRange.new(msg)
      when 110
        raise InvalidBeforeTransID.new(msg)
      when 111
        raise InvalidInteger.new(msg)
      when 112
        raise VersionMismatchException.new(msg)
      when 113
        raise VersionEscalationException.new(msg)
      when 114
        raise InvalidItemIDProvided.new(msg)
      when 115
        raise AssetsAlreadyFetched.new(msg)
      when 116
        raise IndustryJobsAlreadyFetched.new(msg)
      when 117
        raise MarketOrdersAlreadyFetched.new(msg)
      when 118
        raise ExpectedBeforeKillID.new(msg)
      when 119
        raise KillsExhausted.new(msg)
      when 120
        raise UnexpectedBeforeKillID.new(msg)
      when 121
        raise BadBeforeKillID.new(msg)
      when 200
        raise SecurityLevelNotHighEnough.new(msg + ' (Should you be using the full API Key?)')
      when 201
        raise CharacterDoesNotBelongToAccount.new(msg)
      when 202
        raise CachedAPIKeyAuthenticationFailure.new(msg)
      when 203..205
        raise AuthenticationFailure.new(msg)
      when 206
        raise MustHaveAccountantRole.new(msg)
      when 207
        raise NotAvailableForNPCCorps.new(msg)
      when 208
        raise MustHaveAccountantOrTraderRole.new(msg)
      when 209
        raise MustBeDirectorOrCEO.new(msg)
      when 210,212
        raise AuthenticationFailure.new(msg)
      when 211
        raise LoginDeniedByAccountStatus.new(msg)
      when 213
        raise CharacterNeedsFactoryManagerRole.new(msg)
      when 214
        raise CorporationNotInAlliance.new(msg)
      when 500
        raise GetNameInvalid.new(msg)
      when 501
        raise GetIDInvalid.new(msg)
      when 502
        raise CachedUntilException.new(msg)
      when 503
        raise InvalidInput.new(msg)
      when 504
        raise InvalidRace.new(msg)
      when 505
        raise InvalidGender.new(msg)
      when 506
        raise InvalidBloodline.new(msg)
      when 507
        raise InvalidAttribute.new(msg)
      when 508
        raise InvalidRefType.new(msg)
      when 509
        raise NullDataComponent.new(msg)
      when 510
        raise NoCorporationException.new(msg)
      when 511
        raise InvalidAccountKey.new(msg)
      when 512
        raise InvalidCharID.new(msg)
      when 513
        raise CorporateRoleFetchException.new(msg)
      when 514
        raise InvalidCorpID.new(msg)
      when 515
        raise InvalidUserIDOrAPIKey.new(msg)
      when 516 
        raise UserInformationFetchException.new(msg)
      when 517
        raise CSVHeaderRowMismatch.new(msg)
      when 518
        raise TranquilityTimeException.new(msg)
      when 519
        raise StarbaseDetailFetchFailure.new(msg)
      when 520
        raise EveDatabaseConnectionFailure.new(msg)
      when 521
        raise InvalidUsernameOrPassword.new(msg)
      when 522
        raise CharacterRetrevialFailure.new(msg)
      when 523
        raise CorporationRetrevialFailure.new(msg)
      when 900
        raise BetaAccessDenied.new(msg)
      when 901
        raise WebsiteOffline.new(msg)
      when 902
        raise EveDatabaseOffline.new(msg)
      when 903
        raise ObeyCacheTimers.new(msg)
      when 999
        raise UserForcedException.new(msg)
      end
    end
    
    # All API-specific exceptions derrive from this. Useful for rescuing one
    # parent exception to handle all API exceptions.
    class ReveError < StandardError
    end
    
    # 100
    class WalletNotPreviouslyLoaded < ReveError #:nodoc:
    end
    # 101, 103
    class WalletExhausted < ReveError #:nodoc:
    end
    # 102
    class WalletPreviouslyLoaded < ReveError #:nodoc:
    end
    # 104
    class KeyNotFound < ReveError #:nodoc:
    end
    # 105
    class InvalidCharacterID  < ReveError #:nodoc:
    end
    # 106
    class MustProvideUserIDParameterForAuthentication < ReveError #:nodoc:
    end
    # 107
    class InvalidBeforeRefID < ReveError #:nodoc:
    end
    # 108
    class InvalidAccountKey < ReveError #:nodoc:
    end
    # 109
    class AccountKeyOutOfRange < ReveError #:nodoc:
    end
    # 110
    class InvalidBeforeTransID < ReveError #:nodoc:
    end
    # 111
    class InvalidInteger < ReveError #:nodoc:
    end
    # 112
    class VersionMismatchException < ReveError #:nodoc:
    end
    # 113
    class VersionEscalationException < ReveError #:nodoc:
    end
    # 114
    class InvalidItemIDProvided < ReveError #:nodoc:
    end
    # 115
    class AssetsAlreadyFetched < ReveError #:nodoc:
    end
    # 116
    class IndustryJobsAlreadyFetched < ReveError #:nodoc:
    end
    # 117
    class MarketOrdersAlreadyFetched < ReveError #:nodoc:
    end
    # 118
    class ExpectedBeforeKillID < ReveError #:nodoc:
    end
    # 119
    class KillsExhausted < ReveError #:nodoc:
    end
    # 120
    class UnexpectedBeforeKillID < ReveError #:nodoc:
    end
    # 121
    class BadBeforeKillID < ReveError #:nodoc:
    end
    # 200
    class SecurityLevelNotHighEnough < ReveError #:nodoc:
    end
    # 201
    class CharacterDoesNotBelongToAccount < ReveError #:nodoc:
    end
    # 202
    class CachedAPIKeyAuthenticationFailure < ReveError #:nodoc:
    end
    # 203, 204, 205, 210, 212
    class AuthenticationFailure < ReveError #:nodoc:
    end
    # 206
    class MustHaveAccountantRole < ReveError #:nodoc:
    end
    # 207
    class NotAvailableForNPCCorps < ReveError #:nodoc:
    end
    # 208
    class MustHaveAccountantOrTraderRole < ReveError #:nodoc:
    end
    # 209
    class MustBeDirectorOrCEO < ReveError #:nodoc:
    end
    # 211
    class LoginDeniedByAccountStatus < ReveError #:nodoc:
    end
    # 213
    class CharacterNeedsFactoryManagerRole < ReveError #:nodoc:
    end
    # 214
    class CorporationNotInAlliance < ReveError #:nodoc:
    end

    # 500
    class GetNameInvalid < ReveError #:nodoc:
    end
    # 501
    class GetIDInvalid < ReveError #:nodoc:
    end
    # 502
    class CachedUntilException < ReveError #:nodoc:
    end
    # 503
    class InvalidInput < ReveError #:nodoc:
    end
    # 504
    class InvalidRace < ReveError #:nodoc:
    end
    # 505
    class InvalidGender < ReveError #:nodoc:
    end
    # 506
    class InvalidBloodline < ReveError #:nodoc:
    end
    # 507
    class InvalidAttribute < ReveError #:nodoc:
    end
    # 508
    class InvalidRefType < ReveError #:nodoc:
    end
    # 509
    class NullDataComponent < ReveError #:nodoc:
    end
    # 510
    class NoCorporationException < ReveError #:nodoc:
    end
    # 511
    class InvalidAccountKey < ReveError #:nodoc:
    end
    # 512
    class InvalidCharID < ReveError #:nodoc:
    end
    # 513
    class CorporateRoleFetchException < ReveError #:nodoc:
    end
    # 514
    class InvalidCorpID < ReveError #:nodoc:
    end
    # 515
    class InvalidUserIDOrAPIKey < ReveError #:nodoc:
    end
    # 516
    class UserInformationFetchException < ReveError #:nodoc:
    end
    # 517
    class CSVHeaderRowMismatch < ReveError #:nodoc:
    end
    # 518
    class TranquilityTimeException < ReveError #:nodoc:
    end
    # 519
    class StarbaseDetailFetchFailure < ReveError #:nodoc:
    end
    # 520 
    class EveDatabaseConnectionFailure < ReveError #:nodoc:
    end
    # 521
    class InvalidUsernameOrPassword < ReveError #:nodoc:
    end
    # 522
    class CharacterRetrevialFailure < ReveError #:nodoc:
    end
    # 523
    class CorporationRetrevialFailure < ReveError #:nodoc:
    end

    # 900
    class BetaAccessDenied < ReveError #:nodoc:
    end
    class WebsiteOffline  < ReveError #:nodoc:
    end
    # 902
    class EveDatabaseOffline < ReveError #:nodoc:
    end
    # 903 - Obey the %*(&!*@ timers!!!
    class ObeyCacheTimers < ReveError #:nodoc:
    end
    
    # 999
    class UserForcedException < ReveError #:nodoc:
    end

    # this is an Exception to do with the connection to the Eve server failing
    class ReveNetworkStatusException < StandardError
    end
    # used when something is encountered in XML that we didn't expect
    class ReveUnexpectedEntityEncountered < StandardError
    end
  end
end
