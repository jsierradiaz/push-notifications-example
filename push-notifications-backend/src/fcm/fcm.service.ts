import { Injectable, Logger } from '@nestjs/common';
import { GoogleAuth } from 'google-auth-library';
import axios from 'axios';

export type FcmMessage = {
  token: string;
  notification?: {
    title?: string;
    body?: string;
  };
  data?: Record<string, string>;
};

@Injectable()
export class FcmService {
  private readonly logger = new Logger(FcmService.name);

  private get projectId(): string {
    const id = process.env.FIREBASE_PROJECT_ID;
    if (!id) throw new Error('FIREBASE_PROJECT_ID is not set');
    return id;
  }

  private async getAccessToken(): Promise<string> {
    // Check if credentials are provided as JSON string (for Docker/Cloud deployments)
    const credsEnv = process.env.GOOGLE_APPLICATION_CREDENTIALS;

    let auth: GoogleAuth;

    if (credsEnv && credsEnv.trim().startsWith('{')) {
      // Parse JSON credentials directly
      const credentials = JSON.parse(credsEnv);
      auth = new GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
      });
    } else {
      // Use file path (for local development)
      auth = new GoogleAuth({
        scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
      });
    }

    const client = await auth.getClient();
    const accessToken = await client.getAccessToken();
    const tokenString =
      typeof accessToken === 'string' ? accessToken : accessToken?.token;
    if (!tokenString) throw new Error('Unable to obtain access token for FCM');
    return tokenString;
  }

  async send(message: FcmMessage) {
    const accessToken = await this.getAccessToken();
    const url = `https://fcm.googleapis.com/v1/projects/${this.projectId}/messages:send`;

    const payload = {
      message: {
        token: message.token,
        notification: message.notification,
        data: message.data,
      },
    };

    try {
      const res = await axios.post(url, payload, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
      });
      return res.data;
    } catch (err: any) {
      this.logger.error(
        'Error sending FCM message',
        err?.response?.data ?? err?.message,
      );
      const status = err?.response?.status;
      const data = err?.response?.data;
      throw new Error(
        `FCM error${status ? ' ' + status : ''}: ${JSON.stringify(
          data ?? err.message,
        )}`,
      );
    }
  }
}
