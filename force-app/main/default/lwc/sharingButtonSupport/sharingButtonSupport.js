import upsertPerm from '@salesforce/apex/LightningSharing.upsertPerm';
import deletePerm from '@salesforce/apex/LightningSharing.deletePerm';
import { logger } from 'c/lwcLogger';

const sharingButtonColumns = [
  {
    type: 'button',
    typeAttributes: {
      label: 'None',
      name: 'none',
      variant: 'neutral',
      disabled: { fieldName: 'noneDisabled' }
    },
    initialWidth: 85
  },
  {
    type: 'button',
    typeAttributes: {
      label: 'Read',
      name: 'read',
      variant: 'neutral',
      disabled: { fieldName: 'readDisabled' }
    },
    initialWidth: 80
  },
  {
    type: 'button',
    typeAttributes: {
      label: 'Read/Write',
      name: 'read_write',
      variant: 'neutral',
      disabled: { fieldName: 'editDisabled' }
    },
    initialWidth: 125
  }
];

const buttonStylingSingle = existing => {
  // CEO ID: 00G9A0000011wy7UAA
  if (existing && existing.RowCause === 'Owner') {
    return {
      readDisabled: true,
      editDisabled: true,
      noneDisabled: true
    };
  }

  const output = {
    readDisabled: false,
    editDisabled: false,
    noneDisabled: false
  };

  if (existing) {
    if (existing.AccessLevel === 'Read') {
      output.readDisabled = true;
    } else if (existing.AccessLevel === 'Edit') {
      output.editDisabled = true;
    }
  } else {
    output.noneDisabled = true;
  }

  return output;
};

const buttonStyling = (id, existingShares) => {
  // it could be a group or a role on a group
  const existing = existingShares.find(
    share => share.UserOrGroupID === id || share.RoleId === id
  );
  return buttonStylingSingle(existing);
};

const shareDelete = async (UserOrGroupID, recordId) => {
  await deletePerm({
    UserOrGroupID,
    recordId
  });
};

const shareUpdate = async (UserOrGroupID, recordId, level) => {

  await upsertPerm({
    UserOrGroupID,
    recordId,
    level
  });
};

export {
  sharingButtonColumns,
  buttonStyling,
  buttonStylingSingle,
  shareDelete,
  shareUpdate
};
