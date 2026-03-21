import { cafeteriaSettingsRepository } from "@/repositories/cafeteriaSettings.repository";

export const cafeteriaSettingsService = {
  async getCallNumber(): Promise<{ callNumber: string }> {
    const callNumber = await cafeteriaSettingsRepository.getCallNumber();

    return {
      callNumber: callNumber ?? "+20",
    };
  },

  async updateCallNumber(rawCallNumber: string): Promise<{
    success: boolean;
    callNumber: string;
  }> {
    let callNumber = rawCallNumber?.trim();

    if (!callNumber) {
      throw new Error("Call number is required");
    }

    if (!callNumber.startsWith("+20")) {
      callNumber = `+20${callNumber.replace(/^\+?20/, "")}`;
    }

    const stored = await cafeteriaSettingsRepository.setCallNumber(callNumber);

    return {
      success: true,
      callNumber: stored,
    };
  },
};

